package fr.kikko {
	import cmodule.shine.CLibInit;
	import flash.events.DataEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	/**
	 * @author kikko.fr - 2010
	 */
	public class ShineMP3Encoder extends EventDispatcher {
		
		public var wavData:ByteArray;
		public var mp3Data:ByteArray;
		
		private var cshine:Object;
		private var timer:Timer;
		private var initTime:uint;
		
		private var _handler:IEventDispatcher;
		
		public function ShineMP3Encoder(wavData:ByteArray) {
			
			this.wavData = wavData;
		}

		public function set eventMessageHandler(value:IEventDispatcher):void
		{
			_handler = value;
		}

		public function start() : void {
			
			initTime = getTimer();
			
			mp3Data = new ByteArray();
			
			timer = new Timer(1000/30);
			timer.addEventListener(TimerEvent.TIMER, update);
			
			cshine = (new cmodule.shine.CLibInit).init();
			cshine.init(this, wavData, mp3Data);
			
			if(timer) timer.start();
		}
		
		public function shineError(message:String):void {
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, update);
			timer = null;
			
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
		}
		
		public function saveAs(filename:String=".mp3"):void {
			
			(new FileReference()).save(mp3Data, filename);
		}
		
		private function update(event : TimerEvent) : void {
			
			var percent:int = cshine.update();
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, percent, 100));
			
			//trace("encoding mp3...", percent+"%");
			if(_handler){
				_handler.dispatchEvent(new DataEvent(DataEvent.DATA, false, false, "Encoding " + percent +"%"));
			}
			
			if(percent==100) {
				
				//trace("Done in", (getTimer()-initTime) * 0.001 + "s");
				if(_handler){
					_handler.dispatchEvent(new DataEvent(DataEvent.DATA, false, false, "Done Encoding...Saving"));
				}
				
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, update);
				timer = null;
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
		
		public function writeToDrive(filePath:String):void{
			var file:File = File.applicationStorageDirectory.resolvePath( filePath );
			if (file.exists){
				file.deleteFile();
			}else{
				trace( "Doesn't File Exists");
			}
			var wr:File = new File( file.url );
			
			var stream:FileStream = new FileStream();
			stream.open( wr , FileMode.WRITE);
			stream.writeBytes( mp3Data, 0, mp3Data.length );
			stream.close();
			if(_handler){
				_handler.dispatchEvent(new Event("STOP_SECONDS_COUNTER"));
			}
		}
		
	}
}
