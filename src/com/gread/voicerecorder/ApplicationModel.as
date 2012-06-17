package com.gread.voicerecorder
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	public class ApplicationModel extends EventDispatcher
	{
		private static var _appModel:ApplicationModel; 
		
		public static var START_SECONDS_COUNTER:String = "START_SECONDS_COUNTER";
		public static var START_REC_SECONDS_COUNTER:String = "START_REC_SECONDS_COUNTER";
		public static var STOP_SECONDS_COUNTER:String = "STOP_SECONDS_COUNTER";
		
		public function ApplicationModel(enfor:enforcer){}

		public static function getInstance():ApplicationModel{
			if( !_appModel ){
				_appModel = new ApplicationModel(new enforcer());
			}
			
			return _appModel;
		}
		
		private var _audioLibrary:ArrayCollection = new ArrayCollection();
		public function get audioLibrary():ArrayCollection
		{
			return _audioLibrary;
		}
		
		public function set audioLibrary(value:ArrayCollection):void
		{
			_audioLibrary = value;
		}
		
	}
}class enforcer{}