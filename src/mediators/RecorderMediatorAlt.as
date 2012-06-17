package mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	
	import view.RecorderView;

	public class RecorderMediatorAlt
	{
		private var _view:RecorderView;
		private var recordBytes:ByteArray = new ByteArray();
		private var mic:Microphone;
		private var recording:Boolean = false;
		private var sound:Sound;
		private var channel:SoundChannel;
		
		public function RecorderMediatorAlt(){}

		public function get view():RecorderView
		{
			return _view;
		}

		public function set view(value:RecorderView):void
		{
			_view = value;
			
			_view.recordButton.addEventListener(MouseEvent.CLICK, pressRecord);
			
			_view.playButton.addEventListener(MouseEvent.CLICK, pressPlay);
			
			_view.recordButton.enabled = true;
			_view.playButton.enabled = false;
		}
		
		private function pressRecord(event:Event):void{
			if(!recording){
				recording = true;
				mic = Microphone.getMicrophone(-1);
				mic.gain = 100;
				mic.rate = 44;
				mic.setSilenceLevel(0);
				SoundMixer.useSpeakerphoneForVoice = true;
				recordBytes = new ByteArray();
				mic.addEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler);
				_view.recordButton.label = "Recording";
			}else{
				mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler);
				recording = false;
				_view.recordButton.enabled = false;
				_view.playButton.enabled = true;
				_view.recordButton.label = "Record";
			}
		}
		
		protected function micSampleDataHandler(event:SampleDataEvent):void{
			while(event.data.bytesAvailable)
			{
				var sample:Number = event.data.readFloat();
				recordBytes.writeFloat(sample);
			}
			
		}
		
		private function pressPlay(event:Event):void{
			recordBytes.position = 0;
			//recordBytes.length = 0;
			sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, playbackSampleHandler);
				
			channel = sound.play();
			channel.addEventListener(Event.SOUND_COMPLETE, stopPlayback);
			
			_view.recordButton.enabled = false;
			_view.playButton.enabled = false;
			_view.playButton.label = "Playing";
		}
		
		protected function stopPlayback(event:Event):void
		{
			sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, playbackSampleHandler);
			channel.removeEventListener(Event.SOUND_COMPLETE, stopPlayback);
			
			_view.recordButton.enabled = true;
			_view.playButton.enabled = true;
			_view.playButton.label = "Play";
		}
		
		protected function playbackSampleHandler(event:SampleDataEvent):void
		{
			for (var i:int = 0; i < 8092 && recordBytes.bytesAvailable > 0; i++) 
			{
				var sample:Number = recordBytes.readFloat();
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
			
		}
		
		
		
	}
}