package com.gread.voicerecorder.mediators
{
	import com.gread.voicerecorder.ApplicationModel;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	public class VoiceRecorderMediator
	{
		private var _view:VoiceRecorder;
		
		[Bindable]
		private var buttonDP:ArrayCollection = new ArrayCollection();
		
		private var _appmodel:ApplicationModel = ApplicationModel.getInstance(); 
		
		private var _timer:Timer = new Timer(0,0);
		private var _seconds:Number = 1;
		
		public function VoiceRecorderMediator(){}
		
		public function set view(value:VoiceRecorder):void
		{
			_view = value;
			
			init();
		}
		
		protected function init():void
		{
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			_appmodel.addEventListener(ApplicationModel.START_SECONDS_COUNTER, onStartSecondsCounter);
			
			_appmodel.addEventListener(ApplicationModel.START_REC_SECONDS_COUNTER, onStartSecondsCounter);
			
			_appmodel.addEventListener(ApplicationModel.STOP_SECONDS_COUNTER, onStopSecondsCounter);
			
			_appmodel.addEventListener(DataEvent.DATA, onDataEvent)
			
			buttonDP.addItem( {label:'Recorder', id:'0'} );
			buttonDP.addItem( {label:'Player', id:'1'} );
			
			//_view.buttonBar.dataProvider = buttonDP;
			//_view.buttonBar.addEventListener(MouseEvent.CLICK, buttonBarClickHandler);
			
			_appmodel.audioLibrary.addItem({label:"sample1",data:"18.mp3"});
			_appmodel.audioLibrary.addItem({label:"sample2",data:"82.mp3"});
			_appmodel.audioLibrary.addItem({label:"sample3",data:"132.mp3"});
			_appmodel.audioLibrary.addItem({label:"sample4",data:"FlashMicrophoneTest.mp3"});
			
			var file:FileReference = new FileReference();
			var fileArray:Array = File.applicationStorageDirectory.getDirectoryListing();
			for(var i:Number = 0; i < fileArray.length; i++){
				
				var obj:File = fileArray[i];
				if(!obj.isDirectory){
					//trace(obj);
					if(obj.extension == "mp3"){
						_appmodel.audioLibrary.addItem({label:obj.name,data:obj.resolvePath(obj.nativePath).url});
					}
					
				}
				
			}
		
		}
		
		protected function onDataEvent(event:DataEvent):void
		{
			//trace(event.data);
			
			_view.bgColorTitleLbl.color = 0xed1c24; //0x555555
			_view.titleLbl.text = event.data;
		}
		
		protected function onStopSecondsCounter(event:Event = null):void
		{
			_timer.stop();
			_view.bgColorTitleLbl.color = 0x555555;
			_view.titleLbl.text = "VoiceRecorder";
		}
		
		protected function onStartSecondsCounter(event:Event = null):void
		{
			_seconds = 0;
			_timer.start();
			if(event.type == ApplicationModel.START_SECONDS_COUNTER){
				_view.bgColorTitleLbl.color = 0x007236; //0x555555
				_view.titleLbl.text = "Playing";
			}else{
				_view.bgColorTitleLbl.color = 0xed1c24; //0x555555
				_view.titleLbl.text = "Recording";
			}
			
		}
		
		protected function onTimer(event:TimerEvent):void
		{
			_seconds++;
			
			var time:Date = new Date(null,null,null,null,null,_seconds);
			
			//trace(time.hours + ":" + time.minutes + ":" + time.seconds);
			
			_view.timeIndicatorLbl.text = leadingZero(time.hours) + ":" + leadingZero(time.minutes) + ":" + leadingZero(time.seconds); 
		}
		
		private function leadingZero(value:Number):String{
			return value < 10 ? "0" + value.toString() : value.toString();; 
		}

	}
}