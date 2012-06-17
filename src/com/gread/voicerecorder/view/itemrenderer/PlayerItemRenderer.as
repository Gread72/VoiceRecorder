package com.gread.voicerecorder.view.itemrenderer
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.events.FlexEvent;
	import mx.states.State;
	
	import spark.components.Button;
	import spark.components.LabelItemRenderer;
	
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class PlayerItemRenderer extends LabelItemRenderer
	{
		public var playButton:Button; //label="Play" />
		public var stopButton:Button; //label="Stop" />
		
		private var _isPlaying:Boolean = false;
			
		public function PlayerItemRenderer()
		{
			//TODO: implement function
			super();
		}
		
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		public function set isPlaying(value:Boolean):void
		{
			_isPlaying = value;
			if(_isPlaying){
				playButton.visible = false;
				stopButton.visible = true;
			}else{
				playButton.visible = true;
				stopButton.visible = false;
			}
			
		}

		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			super.data = value;
			// the data has changed.  push these changes down in to the 
//			// subcomponents here
		} 
		
		/**
		 * @private
		 * 
		 * Override this method to create children for your item renderer 
		 */	
		override protected function createChildren():void
		{
			super.createChildren();
			// create any additional children for your item renderer here
			
			stopButton = new Button();
			stopButton.label = "Stop";
			addChild(stopButton);
			stopButton.addEventListener(MouseEvent.CLICK, pressStop);
			stopButton.visible = false;
			
			playButton = new Button();
			playButton.label = "Play";
			addChild(playButton);
			playButton.addEventListener(MouseEvent.CLICK, pressPlay);
			playButton.visible = true;
	
		}
		
		protected function pressStop(event:MouseEvent):void
		{
			dispatchEvent(new Event("STOP",true));
			isPlaying = false;
		}
		
		protected function pressPlay(event:MouseEvent):void
		{
			dispatchEvent(new Event("PLAY",true));
			isPlaying = true;
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the item renderer 
		 * sizes itself. For performance reasons, do not call 
		 * super.measure() unless you need to.
		 */ 
		override protected function measure():void
		{
			super.measure();
			// measure all the subcomponents here and set measuredWidth, measuredHeight, 
			// measuredMinWidth, and measuredMinHeight      		
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the background is drawn for 
		 * item renderer.  For performance reasons, do not call 
		 * super.drawBackground() if you do not need to.
		 */
		override protected function drawBackground(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			super.drawBackground(unscaledWidth, unscaledHeight);
			// do any drawing for the background of the item renderer here      		
		}
		
		/**
		 * @private
		 *  
		 * Override this method to change how the background is drawn for this 
		 * item renderer. For performance reasons, do not call 
		 * super.layoutContents() if you do not need to.
		 */
		override protected function layoutContents(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			// layout all the subcomponents here
			if(playButton){
				playButton.width = 100;
				playButton.height = 50;
				playButton.x = unscaledWidth - playButton.width - 20;
				playButton.y = unscaledHeight/2 - playButton.height/2;
 			}
			
			if(stopButton){
				stopButton.width = 100;
				stopButton.height = 50;
				stopButton.x = unscaledWidth - stopButton.width - 20;
				stopButton.y = unscaledHeight/2 - stopButton.height/2;
			}
		}
		
	}
}