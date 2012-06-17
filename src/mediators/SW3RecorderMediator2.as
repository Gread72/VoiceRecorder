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
	import flash.filesystem.File;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import fr.kikko.ShineMP3Encoder;
	
	import org.bytearray.encoder.WaveEncoder;
	
	import view.RecorderView;

	public class SW3RecorderMediator2
	{
		private var _view:RecorderView;
		private var recordBytes:ByteArray = new ByteArray();
		private var mic:Microphone;
		private var recording:Boolean = false;
		private var sound:Sound;
		private var channel:SoundChannel;
		
		protected var player:AudioPlayer = new AudioPlayer();
		protected var source:IAudioSource;
		
		protected var file:FileReference = new FileReference();
		
		private var wavLoader:FileReference;
		private var mp3File:ShineMP3Encoder;
		
		private var rate:Number = 44100;
		
		public function SW3RecorderMediator2(){
			wavLoader = new FileReference();
			wavLoader.addEventListener(Event.SELECT, onFileLoad);
			wavLoader.addEventListener(Event.COMPLETE,  onFileSave);
		}

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
				mic.gain = 50;
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
				
				//saveAudio();
				
				saveAudioDirectly();
			}
		}
		
		private function saveAudio():void
		{
			var waveWriter:WaveEncoder = new WaveEncoder();
			var wavByteArray:ByteArray = waveWriter.encode(recordBytes,2,16,22000);
			file.save(wavByteArray, "sample.wav");
			file.addEventListener(Event.COMPLETE, wavSelected);
			
		}
		
		private function wavSelected(evt:Event):void{
			wavLoader.browse();
		}
		
		private function onFileLoad(evt:Event):void{
			wavLoader.load();
		}
		
		private function saveAudioDirectly():void{
			var waveWriter:WaveEncoder = new WaveEncoder();
			var wavByteArray:ByteArray = waveWriter.encode(recordBytes,1,16,44100);
			mp3File = new ShineMP3Encoder(wavByteArray);
			mp3File.addEventListener(Event.COMPLETE, mp3SaveNow);
			mp3File.start();
		}
		
		private function onFileSave(evt:Event):void{
			mp3File = new ShineMP3Encoder(wavLoader.data);
			mp3File.addEventListener(Event.COMPLETE, mp3SaveNow);
			mp3File.start();
		}
		
		private function mp3SaveNow(evt:Event):void{
			mp3File.saveAs("sample.mp3");
		}
		
		protected function micSampleDataHandler(event:SampleDataEvent):void{
			while(event.data.bytesAvailable)
			{
				var sampleNum:Number = event.data.readFloat();
				recordBytes.writeFloat(sampleNum);
			}
			
		}
		
		private function pressPlay(event:Event):void{
			loadSound("sample.mp3");
			_view.recordButton.enabled = false;
			_view.playButton.enabled = false;
			_view.playButton.label = "Playing";
		}
		
		
		protected function loadSound(url:String):void
		{
			var sound:Sound = new Sound(new URLRequest(url));
			sound.addEventListener(Event.COMPLETE, handleSoundComplete);
		}
		
		protected function handleSoundComplete(e:Event):void
		{
			source = new SoundSource(e.target as Sound);
			
			if(_view.noiseReduce.selected){
				source = BiquadFilter1(source);
			}
			
			player.play(source);
			//player.addEventListener(Event.COMPLETE, onPlayerStop);
			onPlayerStop();
		}
		
		protected function onPlayerStop(event:Event = null):void
		{
			player.removeEventListener(Event.COMPLETE, onPlayerStop);
			
			_view.recordButton.enabled = true;
			_view.playButton.enabled = true;
			_view.playButton.label = "Play";
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