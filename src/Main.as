package 
{
	import crowd.core.ISocialType;
	import crowd.Crowd;
	import crowd.impl.mailru.MailruInitData;
	import crowd.impl.vkontakte.VkontakteInitData;

	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Shirobok Pavel aka ramshteks
	 */
	public class Main extends Sprite 
	{
		private var _crowd:Crowd;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			var sc:ISocialType;
			
			_crowd = new Crowd(true);
			
			_crowd.addInitData(new VkontakteInitData(stage));
			_crowd.addInitData(new MailruInitData("sdfsdf"));
			
			_crowd.debugFilePath = "debug_data.xml";
			
			_crowd.addEventListener(Event.COMPLETE, onCrowdComplete);
			_crowd.addEventListener(ErrorEvent.ERROR, onCrowdError);
			_crowd.startCrowd(stage);
		}
		
		private function onCrowdComplete(e:Event):void 
		{
			trace(e);
			trace()
			/*trace("rewuest builder", Crowd.environment.request_builder);
			trace("js_api", Crowd.environment.js_api);
			trace("flash_vars", Crowd.environment.flash_vars);
			trace("soc_type", Crowd.environment.soc_type);
			trace("social_data", Crowd.environment.social_data);*/
		}
		
		private function onCrowdError(e:ErrorEvent):void 
		{
			trace(e);
		}
		
	}
	
}