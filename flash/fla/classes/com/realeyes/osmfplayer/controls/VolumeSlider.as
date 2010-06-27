package com.realeyes.osmfplayer.controls
{
	import org.osflash.signals.Signal;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	//import com.realeyes.osmfplayer.events.ControlBarEvent;
	
	/**
	 * Slider for control bar to control volume. Registration for the
	 * slider symbol is assumed to be in the bottom left.
	 * 
	 * @author	RealEyes Media
	 * @author	Thanh Tran
	 * @version	1.0
	 */
	public class VolumeSlider extends MovieClip
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		
		public var value_mc:MovieClip;
		public var volumeSet: Signal;
		
		protected var _upperBound:Number;
		protected var _lowerBound:Number;
		protected var _activeRange:Number;
		
		//private var _displayBelow:Boolean = false;
		private var _mouseDown:Boolean = false;
		
		
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function VolumeSlider()
		{
			super();
			this.visible = false;
			stop();
			
			//NOTE: these calculations assume the registration point of the symbol at bottom left
			_lowerBound = height - value_mc.y;
			_upperBound = height - value_mc.height - _lowerBound;
			
			_activeRange = value_mc.height;
			
			_initListeners();
			
			volumeSet = new Signal(Number);
		}
		
		
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		/**
		 * Initializes listening for mouse events
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			addEventListener( MouseEvent.MOUSE_DOWN, _onMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, _onMouseUp );
			addEventListener( MouseEvent.MOUSE_MOVE, _onMouseMove );
		}
		
		/**
		 * Adjusts the volume based on slider position. Dispatches a
		 * ControlBarEvent.VOLUME event.
		 * 
		 * @see		ControlBarEvent
		 * @return	void
		 */
		protected function _updateVolume():void
		{
			if( mouseY > _upperBound - 1 && mouseY < _activeRange + _upperBound )
			{
				var pixelValue:Number = height - mouseY - _lowerBound;
				var volumeValue:Number = int( ( pixelValue / _activeRange ) * 100 ) / 100;
				
				//trace( "pixelValue: " + pixelValue + ", volumeValue: " + volumeValue );
				
				value_mc.height = pixelValue;
				
				//dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME, volumeValue, 0, true ) );
				volumeSet.dispatch(volumeValue);
			}
		}
		
		/**
		 * While dragging, stops the updating of the volume
		 * 
		 * @return	void
		 */
		private function _stopUpdatingVolume():void
		{
			_mouseDown = false;
			stage.addEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
		}
		
		
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * Start updating the volume while dragging
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onMouseDown( p_evt:MouseEvent ):void
		{
			_updateVolume();
			
			_mouseDown = true;
			stage.addEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
		}
		
		/**
		 * Stop update the volume when released
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onMouseUp( p_evt:MouseEvent ):void
		{
			_stopUpdatingVolume();
		}
		
		/**
		 * Update the volume while dragging
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onMouseMove( p_evt:MouseEvent ):void
		{
			if( _mouseDown )
			{
				_updateVolume();
			}
		}
		
		/**
		 * When the mouse is released outside of the slider, stop
		 * updating the volume.
		 *
		 * @param	p_evt	(MouseEvent)
		 * @return	void
		 */ 
		private function _onStageMouseUp( p_evt:MouseEvent ):void
		{
			_stopUpdatingVolume();
		}
	}
}