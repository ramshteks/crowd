package crowd
{
	//{imports
	import com.ramshteks.as3.*;
	import com.ramshteks.as3.debug.*;
	import com.ramshteks.as3.vars_holder.*;

	import crowd.core.*;
	import crowd.events.*;
	import crowd.impl.mailru.*;
	import crowd.impl.odnoklassniki.*;
	import crowd.impl.vkontakte.*;

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	//}
	
	//{events - meta tags
	[Event(name = "complete", type = "flash.events.Event")]
	[Event(name = "error"   , type = "flash.events.ErrorEvent")]
	[Event(name = "log_message", type="crowd.events.LogEvent")]
	//}
	
	/**
	 * Crowd - class  of the classes in over the world and all time since current moment
	 * @author Shirobok Pavel aka ramshteks
	 */
	public final class Crowd extends EventDispatcher {
		//noinspection JSUnusedGlobalSymbols
		/**
		 * Версия сборки
		 */
		public static const Version:String = "@Version@";
		
		//{statics
		private static var _environment:ICrowdEnvironment;
		private static var _synchronizer:RestApiSynchronizer;
		private static var _rest_api:IRestApi;
		private static var _soc_type:String = '';
		private static var _debug_mode:Boolean = false;
		//}
		//{privates
		private var _debugFilePath:String = "debug_data.xml";
		private var _realFlashVars:FlashVarsHolder;
		private var _alreadyStarted:Boolean = false;
		private var _log_to_trace:Boolean;
		private var _initDataHolder:Array = [];
		private var _loader:URLLoader;
		//}
		
		//{public methods
		/**
		 * Конструктор
		 * @param log_to_trace true если необходимо трасировка лог-сообщений
		 */
		public function Crowd(log_to_trace:Boolean = true) {
			_log_to_trace = log_to_trace;
		}

		/**
		 * Добавление стартовых инициализационных данных для различных соц сетей
		 * @see crowd.impl.vkontakte.VkontakteInitData
		 * @see crowd.impl.odnoklassniki.OdnoklassnikiInitData
		 * @see crowd.impl.mailru.MailruInitData
		 *
		 * @param initData экземпляр инициализационных данных
		 */
		public function addInitData(initData:ICrowdInitData):void {
			Assert.isIncorrect(_alreadyStarted, "Crowd framework already started");
			Assert.isNull(_initDataHolder[initData.soc_type], "For '" + initData.soc_type + "' init data already registered");
			
			_initDataHolder[initData.soc_type] = initData;
		}

		/**
		 * Запуск Crowd
		 * @param stage необходим для изъятия flashvars
		 */
		public function startCrowd(stage:Stage):void {
			Assert.isIncorrect(_alreadyStarted, "Crowd framework already started");

			_alreadyStarted = true;

			_realFlashVars = new FlashVarsHolder(stage);
			_soc_type = SocialTypes.getSocialTypeByFlashVars(_realFlashVars);
			if (_soc_type == SocialTypes.UNKNOWN) {
				startAsStandalone();
			} else {
				try {
					startAsInRealSocialNetwork();
				} catch (e:Error) {
					dispatchLog(e.name, e.message)
				}
			}

		}
		//}
		
		//{private methods
		private function startAsStandalone():void {
			dispatchLog("run as standalone");
			
			_debug_mode = true;
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onComplete);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onCommonLoadingError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onCommonLoadingError);
			_loader.load(new URLRequest(_debugFilePath));
		}
		
		private function startAsInRealSocialNetwork():void {
			dispatchLog("run as in real social network");
			
			dispatchLog("initing start logic");
			var initData:ICrowdInitData = _initDataHolder[_soc_type];
			var factory:ISocialFactory = getSocialFactoryByType(_soc_type, initData, _realFlashVars);
			var env:ICrowdEnvironmentInitializer = factory.getEnvironmentInitializer();
			
			if (env == null) {
				dispatchError(StringUtils.printf("Unsupported social type '%s%'", _soc_type));
				return;
			}
			
			env.setFlashVarsHolder(_realFlashVars);
			
			dispatchLog("init synchronizer");
			_synchronizer = constructSynchronizer(initData);
			
			dispatchLog("init rest api");
			var rest_api_initializer:IRestApiInitializer = factory.getRestApiInitializer();
			rest_api_initializer.setEnvironment(_environment);
			rest_api_initializer.setSynchronizer(_synchronizer);
			_rest_api = rest_api_initializer;
			
			dispatchLog("init js api");
			var js:IJSApi = factory.getJSApi();
			js.addEventListener(Event.CONNECT, onJSConnect);
			js.addEventListener(JSApiErrorEvent.CONNECT_FAILED, onJSConnectFailed);
			env.setJSApi(js);
			_environment = env;
			
			var jsMessage:String = "connecting js to environment";
			if (_environment.soc_type == SocialTypes.MAILRU) {
				jsMessage += "Note: If init stops on this step, it may mean, that it is not installed System.allowDomain";
			}
			dispatchLog(jsMessage);
			js.init(factory.getJSApiInitParams());
		}
		
		private function onJSConnectFailed(e:JSApiErrorEvent):void {
			dispatchError(StringUtils.printf("JS connection crash with message '%m%'", e.message));
		}
		
		private function onJSConnect(e:Event):void {
			dispatchLog("Init complete: Crowd ready to rock!");
			dispatchComplete();
		}
		
		private function onCommonLoadingError(e:ErrorEvent):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Error loading debug file. Type:" + e.type));
		}
		
		private function onComplete(e:Event):void {
			var xml:XML;
			
			try {
				xml = new XML(_loader.data);
			}catch (e:Error) {
				dispatchError("Debug-XML parsing error, maybe xml not xml? ;)");
				return;
			}
			
			var default_soc_type:String = xml.@default;
			if (!SocialTypes.isSupportingSocialType(default_soc_type)) {
				dispatchError("Default social type '" + default_soc_type + "' not supporting. Maybe later? ;)");
				return;
			}
			
			var xml_socData:XMLList = xml.child(default_soc_type);
			
			if (xml_socData.toXMLString().length == 0) {
				dispatchError("Default soc_type not found in debug xml. See root attributes 'default'");
				return;
			}
			
			var initData:ICrowdInitData = _initDataHolder[default_soc_type];
			if (initData == null) {
				dispatchError("Init data for '" + default_soc_type + "' not defined. Use Crowd#registerSocialInitData method");
				return;
			}
			
			var varsHolder:IVarsHolder = new XMLVarsHolder(xml_socData);
			
			var factory:ISocialFactory = getSocialFactoryByType(default_soc_type, initData, varsHolder);
			if (factory == null) {
				dispatchError("No social factory for type '" + default_soc_type + "'");
				return;
			}
			
			dispatchLog("default social type '" + default_soc_type + "'");
			_synchronizer = constructSynchronizer(initData);
			
			
			
			var envIniter:ICrowdEnvironmentInitializer = factory.getEnvironmentInitializer();
			envIniter.setFlashVarsHolder(varsHolder);
			envIniter.setJSApi(initData.mock_js);
			
			_soc_type = envIniter.soc_type;
			_environment = envIniter as ICrowdEnvironment;
			
			var rest_api_initializer:IRestApiInitializer = factory.getRestApiInitializer();
			rest_api_initializer.setEnvironment(_environment);
			rest_api_initializer.setSynchronizer(_synchronizer);
			
			_rest_api = rest_api_initializer;
			
			dispatchLog("Init complete: Crowd ready to rock!");
			dispatchComplete();
		}

		private static function getSocialFactoryByType(soc_type:String, initData:ICrowdInitData, flash_vars:IVarsHolder):ISocialFactory {
			var result:ISocialFactory;
			
			switch(soc_type) {
				case SocialTypes.VKONTAKTE:
					result = new VkontakteFactory(initData as VkontakteInitData);
					break;
				/*@FULL_VERSION@*/
				case SocialTypes.MAILRU:
					result = new MailruFactory(initData as MailruInitData);
					break;
					
				case SocialTypes.ODNOKLASSNIKI:
					return new OdnoklassnikiFactory(initData as OdnoklassnikiInitData, flash_vars);
					break;//*/
			}
			
			return result;
		}
		
		private function dispatchLog(...log:Array):void {
			if (_log_to_trace) {
				var str:String = "[crowd log] " + log.join(" ");
				trace(str);
				dispatchEvent(new LogEvent(LogEvent.LOG_MESSAGE, str));
			}
		}
		
		private function dispatchComplete():void {
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function dispatchError(message:String = ""):void {
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}
		
		private static function constructSynchronizer(initData:ICrowdInitData):RestApiSynchronizer {
			return new RestApiSynchronizer(1 / initData.request_per_second_limit * 1000);
		}
		//}
		
		//{setters and getters
		//noinspection JSUnusedGlobalSymbols
		public function get debugFilePath():String {
			return _debugFilePath;
		}
		
		public function set debugFilePath(value:String):void {
			_debugFilePath = value;
		}
		
		static public function get environment():ICrowdEnvironment {
			return _environment;
		}
		
		static public function get rest_api():IRestApi {
			return _rest_api;
		}
		
		public static function get isDebugMode():Boolean {
			return _debug_mode;
		}
		
		static public function get soc_type():String {
			return _soc_type;
		}
		//}
	}

}