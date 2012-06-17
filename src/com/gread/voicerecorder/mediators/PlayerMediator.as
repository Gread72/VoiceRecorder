package com.gread.voicerecorder.mediators
{
	import com.gread.voicerecorder.ApplicationModel;
	import com.gread.voicerecorder.view.PlayerView;
	import com.gread.voicerecorder.view.itemrenderer.PlayerItemRenderer;
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
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import fr.kikko.ShineMP3Encoder;
	
	import mx.collections.ArrayCollection;
	
	import org.bytearray.encoder.WaveEncoder;

	public class PlayerMediator
	{
		private var _view:PlayerView;
		private var recordBytes:ByteArray = new ByteArray();
		private var mic:Microphone;
		private var recording:Boolean = false;
		private var sound:Sound;
		private var channel:SoundChannel;
		
		protected var player:AudioPlayer = new AudioPlayer();
		protected var source:IAudioSource;
		
		protected var file:FileReference = new FileReference();
		
		private var wavLoader:FileReference;
		
		private var _appmodel:ApplicationModel = ApplicationModel.getInstance(); 
		
		public function PlayerMediator(){
		}

		public function get view():PlayerView
		{
			return _view;
		}

		public function set view(value:PlayerView):void
		{
			_view = value;
			
//			var audioList:ArrayCollection = new ArrayCollection();
//			//audioList.addItem({label:"Bells",data:"bells.mp3"});
//			audioList.addItem({label:"sample1",data:"18.mp3"});
//			audioList.addItem({label:"sample2",data:"82.mp3"});
//			audioList.addItem({label:"sample3",data:"132.mp3"});
//			audioList.addItem({label:"sample4",data:"FlashMicrophoneTest.mp3"});
			//audioList.addItem({label:"radiohead",data:"RH_LotusFlower.MP3"});
			_view.audioList.dataProvider = _appmodel.audioLibrary;
			_view.audioList.addEventListener("PLAY", pressPlay);
			_view.audioList.addEventListener("STOP", pressStop);
		
		}
		
		private function pressPlay(event:Event):void{
			if(_view.audioList.selectedItem != undefined){
				_appmodel.dispatchEvent(new Event(ApplicationModel.START_SECONDS_COUNTER));
				loadSound(_view.audioList.selectedItem.data);
			}
		}
		
		private function pressStop(event:Event):void{
			_appmodel.dispatchEvent(new Event(ApplicationModel.STOP_SECONDS_COUNTER));
			player.stop();
		}
		
		protected function loadSound(url:String):void
		{
			var sound:Sound = new Sound(new URLRequest(url));
			sound.addEventListener(Event.COMPLETE, handleSoundComplete);
		}
		
		protected function handleSoundComplete(e:Event):void
		{
			source = new SoundSource(e.target as Sound);
			
			if(_view.noiseReduce1.selected || _view.noiseReduce2.selected){
				if(_view.noiseReduce1.selected) source =  ToneFilter(source);
					 
				if(_view.noiseReduce2.selected) source = BiquadFilter1(source);
				
				player.play(source);
			}else{
				player.play(source);
			}
			
			player.addEventListener(Event.SOUND_COMPLETE, onAudioComplete);
			
		}
		
		protected function onAudioComplete(event:Event):void
		{
			//trace("onAudioComplete");
			_appmodel.dispatchEvent(new Event(ApplicationModel.STOP_SECONDS_COUNTER));
			// when audio has completed playing reset buttons
			if(_view.audioList.selectedItem != undefined){
				for(var i:Number = 0; i < _view.audioList.dataGroup.numChildren; i++){
					if(_view.audioList.selectedItem == _view.audioList.dataProvider[i]){
						var obj:PlayerItemRenderer = PlayerItemRenderer(_view.audioList.dataGroup.getChildAt(i));
						obj.isPlaying = false;
					}
				}
				
			}
		}
		
		protected function ToneFilter(src:IAudioSource):IAudioFilter{
			var filter:ToneControlFilter = new ToneControlFilter(src);
			filter.bass = -100;
			filter.treble = -100;
			//filter.bassShape = ToneControlFilter.PEAK;
			//filter.trebleShape = ToneControlFilter.LOW_SHELF;
			
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
			var filter:GainFilter = new GainFilter(source, -1);
			return filter;
		}
		
		protected function GainFilter3(src:IAudioSource):IAudioFilter{
			var filter:GainFilter = new GainFilter(source, 0);
			return filter;
		}
		
		protected function BiquadFilter1(src:IAudioSource):IAudioFilter{
			var filter:BiquadFilter = new BiquadFilter(source, BiquadFilter.BAND_PASS_TYPE,1024,1);
			//1024
			//4096
			return filter;
		}
		
		
		
	}
}