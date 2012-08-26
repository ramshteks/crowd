package crowd_framework.vk_impl.environment 
{
	import crowd_framework.core.environment.ISocialData;
	import com.adobe.crypto.MD5;
	import com.ramshteks.as3.vars_holder.IVarsHolder;
	import crowd_framework.core.environment.ICrowdEnvironmentInitializer;
	import crowd_framework.core.environment.IRequestBuilder;
	import crowd_framework.core.js_api.IJSApi;
	import crowd_framework.SocialTypes;
	import crowd_framework.vk_impl.soc_init_data.VkontakteInitData;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	/**
	 * ...
	 * @author 
	 */
	public class VkontakteEnvironment implements ICrowdEnvironmentInitializer 
	{
		//ISocialData
		private var _api_url:String;
		private var _application_id:String;
		private var _user_id:String;
		private var _referrer:String;
		
		//Vk specified
		private var _secret:String;
		private var _auth_key:String;
		private var _sid:String;
		
		private var _initData:VkontakteInitData;
		
		private var _flashVarsHolder:IVarsHolder;
		
		//JS API
		private var _javaScript:IJSApi;
		
		public function VkontakteEnvironment(initData:VkontakteInitData) 
		{
			_initData = initData;
		}
		
		public function parseVars(vars:IVarsHolder):void 
		{
			
		}
		
		public function setJSApi(js_api:IJSApi):void 
		{
			_javaScript = js_api;
		}
		
		public function setFlashVarsHolder(vars:IVarsHolder):void 
		{
			_flashVarsHolder = vars;
			
			_application_id = vars.getVar("api_id");
			_api_url = vars.getVar("api_url");
			
			_user_id = vars.getVar("viewer_id");
			_sid = vars.getVar("sid");
			_secret = vars.getVar("secret");
			_referrer = vars.getVar("referrer");
			
			var private_key:String = vars.getVar("private_key");
			if (private_key != "") {
				_auth_key = MD5.hash(_application_id + "_" + _user_id + "_" + private_key);
			}else {
				_auth_key = vars.getVar("auth_key");
			}
		}
		
		public function get request_builder():IRequestBuilder 
		{
			return null;
		}
		
		public function get js_api():IJSApi 
		{
			return null;
		}
		
		public function get social_data():ISocialData 
		{
			return null;
		}
		
		public function get flash_vars():IVarsHolder 
		{
			return null;
		}
		
		public function get soc_type():String 
		{
			return SocialTypes.VKONTAKTE;
		}
		
		public function get application_id():String 
		{
			return null;
		}
		
		public function get user_id():String 
		{
			return null;
		}
		
		public function get referrer():String 
		{
			return null;
		}
		
		public function get api_url():String 
		{
			return null;
		}
		
		/*public function getLocalData(formatter:IFormatter = null):String 
		{
			if (formatter == null) formatter = new XMLFormatter();
			return formatter.getString([new Param("sid", _sid), new Param("secret", _secret), new Param("viewer_id", _user_id)]);
		}
		
		public function getAPIRequest(params:Array):URLRequest 
		{
			var req:URLRequest = NetUtil.getPostURLRequest(_api_url);
			
			var n_params:Array = getStandardParams();
			
			for (var i:int = 0; i < params.length; i++) {
				n_params.push(params[i]);
			}
			
			var sig:String = NetUtil.getSignature(n_params, _user_id, _secret);
			
			n_params.push(new Param("sig", sig));
			n_params.push(new Param("sid", _sid));
			
			req.data = new URLVariables(n_params.join("&"));
			trace(n_params.join("&"))
			return req;
		}
		
		private function getStandardParams():Array {
			return [new Param("v", "3.0"), new Param("format", "XML"),new Param("api_id", _application_id)];
		}
		
		public function getAuthVariables():URLVariables 
		{
			return new URLVariables(StringUtils.printf("uid=%uid%&auth_key=%key%&soc_type=%type%", _user_id, _auth_key, SocialTypes.VKONTAKTE));// "uid=" + _user_id + "&auth_key=" + _auth_key + "&soc_type=" + );
		}
		
		public function get requestMaker():IRequestMaker 
		{
			return this as IRequestMaker;
		}
		
		public function get socialData():ISocialData 
		{
			return this as ISocialData;
		}
		
		public function get javascriptApi():ISocialJavaScriptAPI 
		{
			return _javaScript as ISocialJavaScriptAPI;
		}
		
		
		
		public function get flashVars():IVarsHolder 
		{
			return _flashVarsHolder;
		}
		
		public function get type():String {
			return SocialTypes.VKONTAKTE;
		}	*/
	}
}