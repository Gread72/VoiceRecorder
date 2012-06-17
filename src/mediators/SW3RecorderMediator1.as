package mediators
{
	import com.noteflight.standingwave3.elements.AudioDescriptor;
	import com.noteflight.standingwave3.elements.IAudioFilter;
	import com.noteflight.standingwave3.elements.IAudioSource;
	import com.noteflight.standingwave3.elements.Sample;
	import com.noteflight.standingwave3.filters.*;
	import com.noteflight.standingwave3.output.AudioPlayer;
	import com.noteflight.standingwave3.sources.SoundSource;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	
	import view.RecorderView;

	public class SW3RecorderMediator1
	{
		private var _view:RecorderView;
		private var recordBytes:ByteArray = new ByteArray();
		private var mic:Microphone;
		private var recording:Boolean = false;
		private var sound:Sound;
		private var channel:SoundChannel;
		
		protected var player:AudioPlayer = new AudioPlayer();
		protected var source:IAudioSource;
		
		protected var sample:Sample;
		
		public function SW3RecorderMediator1(){}

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
				mic = Microphone.getMicrophone();
				mic.gain = 100;
				mic.rate = 44;
				recordBytes = new ByteArray();
				//var audioDesc:AudioDescriptor = new AudioDescriptor(AudioDescriptor.RATE_44100, AudioDescriptor.CHANNELS_STEREO);
				//sample = new Sample(audioDesc,mic.framesPerPacket);
				mic.addEventListener(SampleDataEvent.SAMPLE_DATA, micSampleDataHandler);
				_view.recordButton.label = "Recording";
			}else{
				//sample.readWavBytes(recordBytes,44,2,mic.framesPerPacket); 
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
				var sampleNum:Number = event.data.readFloat();
				recordBytes.writeFloat(sampleNum);
			}
			
		}
		
		private function pressPlay(event:Event):void{
			
			sample.position = 0;
			player.play(sample);
			player.addEventListener(Event.COMPLETE);
	
//			var filter:IAudioFilter =  EchoFilter1(BiquadFilter1(source));
//			var filter:IAudioFilter = BiquadFilter1(source);
//			var sourceResult:IAudioSource = IAudioSource(filter);
//			player.play(source);
//			channel = player.channel;
//			channel.addEventListener(Event.SOUND_COMPLETE, stopPlayback);
			
			
//			recordBytes.position = 0;
//			sound = new Sound();
//			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, playbackSampleHandler);
//			channel = sound.play();
//			channel.addEventListener(Event.SOUND_COMPLETE, stopPlayback);
			
			_view.recordButton.enabled = false;
			_view.playButton.enabled = false;
			_view.playButton.label = "Playing";
		}
		
		protected function stopPlayback(event:Event):void
		{
			//sound.removeEventListener(SampleDataEvent.SAMPLE_DATA, playbackSampleHandler);
			channel.removeEventListener(Event.SOUND_COMPLETE, stopPlayback);
			player.removeEventListener(Event.COMPLETE, stopPlayback);
			
			_view.recordButton.enabled = true;
			_view.playButton.enabled = true;
			_view.playButton.label = "Play";
		}
		
		protected function playbackSampleHandler(event:SampleDataEvent):void
		{
			for (var i:int = 0; i < 8192 && recordBytes.bytesAvailable > 0; i++) 
			{
				var sample:Number = recordBytes.readFloat();
				event.data.writeFloat(sample);
				event.data.writeFloat(sample);
			}
			
		}
		
		protected function ToneFilter(src:IAudioSource):IAudioFilter{
			var filter:ToneControlFilter = new ToneControlFilter(src);
			filter.bass = -1;
			filter.treble = -100;
			filter.bassShape = ToneControlFilter.PEAK;
			filter.trebleShape = ToneControlFilter.LOW_SHELF;
			
			return filter;
		}
		
		private function EchoFilter1(src:IAudioSource):IAudioFilter{
			var filter:EchoFilter = new EchoFilter(src,0.2,0.2,0.2);
			return filter;
		}
		
		protected function GainFilter1(src:IAudioSource):IAudioFilter{
			var filter:GainFilter = new GainFilter(source, -20);
			return filter;
		}
		
		protected function GainFilter2(src:IAudioSource):IAudioFilter{
			var filter:GainFilter = new GainFilter(source, 20);
			return filter;
		}
		
		protected function GainFilter3(src:IAudioSource):IAudioFilter{
			var filter:GainFilter = new GainFilter(source, 0);
			return filter;
		}
		
		protected function BiquadFilter1(src:IAudioSource):IAudioFilter{
			var filter:BiquadFilter = new BiquadFilter(source, BiquadFilter.BAND_PASS_TYPE,4096,1);
			return filter;
		}
		
		
		
	}
}