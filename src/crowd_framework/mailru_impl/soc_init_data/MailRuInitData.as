package crowd_framework.mailru_impl.soc_init_data 
{
	import crowd_framework.core.js_api.IJSApi;
	import crowd_framework.core.js_api.MockJS;
	import crowd_framework.core.soc_init_data.ICrowdInitData;
	import crowd_framework.SocialTypes;
	
	/**
	 * ...
	 * @author Shirobok Pavel aka ramshteks
	 */
	public class MailRuInitData implements ICrowdInitData 
	{
		private var _mock_js:IJSApi;
		private var _secret:String;
		
		public function MailRuInitData(secret:String) 
		{
			_secret = secret;
			_mock_js = new MockJS(soc_type);
		}
		
		/* INTERFACE crowd_framework.core.soc_init_data.ICrowdInitData */
		
		public function get request_per_second_limit():int 
		{
			return 3;
		}
		
		public function set mock_js(value:IJSApi):void 
		{
			_mock_js = value;
		}
		
		public function get mock_js():IJSApi 
		{
			return _mock_js;
		}
		
		public function get soc_type():String 
		{
			return SocialTypes.MAILRU;
		}
		
		public function get secret():String 
		{
			return _secret;
		}
		
	}

}