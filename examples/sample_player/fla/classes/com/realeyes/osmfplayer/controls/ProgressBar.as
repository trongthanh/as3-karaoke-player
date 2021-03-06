package com.realeyes.osmfplayer.controls
{
	import org.osflash.signals.Signal;
	//import com.realeyes.osmfplayer.events.ControlBarEvent;
	
	import flash.display.MovieClip;
	//import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * Shows progress of the media playback in a slider bar. Also allows
	 * for seeking through the media by using the scrubber. Also shows 
	 * buffer progress.
	 * 
	 * @author	RealEyes Media
	 * @author	Thanh Tran
	 * @version	1.0
	 */
	public class ProgressBar extends MovieClip implements ISkinSprite
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		/**
		 * seek event, argument (percent: Number);
		 */
		public var seeked: Signal;
		public var seeking: Signal;
		
		public var scrubber_mc:ToggleButton;
		
		public var current_mc:MovieClip;
		public var loaded_mc:MovieClip;
		
		public var live_mc:MovieClip;
		
		public var bg_mc:MovieClip;
		//moving shadow when progressbar is resized
		public var rightShadowMovie: MovieClip;
		
		protected var _currentPercent:Number;
		protected var _currentLoadPercent:Number;
		
		protected var _dragging:Boolean = false;
		protected var _scrubberPadding:Number = 0;
		protected var _scrubberWidth:Number = 0;
		protected var _activeRange:Number;
		
		protected var _isLive:Boolean;
		
		protected var _anchor:String = "both";
		
		//check for Boolean instead of: if (scrubber_mc)  
		protected var _hasScrubber: Boolean;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function ProgressBar()
		{
			super();
			
			//this.addEventListener( Event.ADDED_TO_STAGE, _onAdded );
			//trace(live_mc);
			//trace(current_mc);
			//trace(loaded_mc);
			//trace(scrubber_mc);
			//will not add live MC until it is really used
			//live_mc.visible = false;
			removeChild(live_mc);
			
			current_mc.scaleX = 0;
			loaded_mc.width = 0;
			
			if( scrubber_mc )
			{
				_scrubberWidth = scrubber_mc.width;
				scrubber_mc.toggle = false;
				_hasScrubber = true;
			}
			
			_scrubberPadding = _scrubberWidth / 2;
			_activeRange = width - _scrubberWidth;
			
			_initListeners();
			
			seeked = new Signal(Number);
			seeking = new Signal(Number);
		}
		
		
		
		/////////////////////////////////////////////
		//  CONTROL METHODS
		/////////////////////////////////////////////
		/**
		 * Initialize listenrs for mouse events
		 * 
		 * @return	void
		 */
		private function _initListeners():void
		{
			addEventListener( MouseEvent.CLICK, _onClick );
			
			if( _hasScrubber )
			{
				scrubber_mc.addEventListener( MouseEvent.MOUSE_DOWN, _onScrubberMouseDown );
				scrubber_mc.addEventListener( MouseEvent.MOUSE_UP, _onScrubberMouseUp );
			}
		}
		
		/**
		 * Sets the current progress indicator at a certain percentage of the
		 * bar's width. If showing playback progress, it also moves the scrubber.
		 * 
		 * @param	p_value	(Number) percentage of the bar to place the progress indicator at
		 * @return	void
		 */ 
		public function setCurrentBarPercent( p_value:Number ):void
		{
			//trace("current percent: " + (p_value) );
			if( !_dragging )
			{
				//current_mc.width = Math.round( _scrubberWidth + _activeRange * p_value );
				current_mc.width = int( _scrubberWidth + _activeRange * p_value );
				//trace("setCurrentBarPercent: " + p_value);
				//current_mc.scaleX = p_value;
				
				if( _hasScrubber )
				{
					//scrubber_mc.x = Math.round( current_mc.width - _scrubberWidth );
					scrubber_mc.x = int( current_mc.width - _scrubberWidth );
				}
			}
			
			_currentPercent = p_value;
		}
		
		/**
		 * Updates the loading indicator bar to be at a certain percentage of the
		 * bar's width.
		 * 
		 * @param	p_value	(Number) percentage of the bar to place the progress indicator at
		 * @return	void
		 */
		public function setLoadBarPercent( p_value:Number ):void
		{
			//trace("load percent: " + p_value);
			if( p_value <= 1 )
			{
				loaded_mc.width = Math.round( _scrubberWidth + _activeRange * p_value );
			}
			else if( !isNaN( p_value ) )
			{
				loaded_mc.width = bg_mc.width;
			}
			
			//loaded_mc.scaleX = p_value ;
			
			_currentLoadPercent = p_value;
		}
		
		/**
		 * Stops dragging of the scrubber and seeks for recorded content.
		 * 
		 * @return	void
		 */
		private function _stopScrubberDrag():void
		{
			_dragging = false;
			
			scrubber_mc.removeEventListener( MouseEvent.MOUSE_MOVE, _onScrubberMouseMove );
			scrubber_mc.stopDrag();
			
			stage.removeEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
			
			if( !isLive )
			{
				//dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK, 0, scrubber_mc.x / _activeRange, true ) );
				seeked.dispatch(scrubber_mc.x / _activeRange);
			}
		}
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		/**
		 * Is the content live?
		 * 
		 * @return	Boolean
		 */
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function set isLive( p_value:Boolean ):void
		{
			_isLive = p_value;
			
			if( _isLive )
			{
				if( scrubber_mc )
				{
					scrubber_mc.visible = false;
				}
				current_mc.visible = false;
				loaded_mc.visible = false;
				
				//live_mc.visible = true;
				addChildAt(live_mc, getChildIndex(bg_mc));
			}
			else
			{
				if( scrubber_mc )
				{
					scrubber_mc.visible = true;
				}
				current_mc.visible = true;
				loaded_mc.visible = true;
				
				//live_mc.visible = false;
				if(contains(live_mc)) removeChild(live_mc);
			}
		}
		
		public override function set width( value:Number ):void
		{
			bg_mc.width = value;
			rightShadowMovie.x = value;
			_activeRange = value - _scrubberWidth;
			
			setCurrentBarPercent( _currentPercent );
			setLoadBarPercent( _currentLoadPercent );
		}
		
		
		
		
		public function get anchor():String
		{
			return _anchor;
		}
		
		public function set anchor(value:String):void
		{
			_anchor = value;
		}
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * When the bar is clicked on during playback, seek to
		 * that point.
		 * 
		 * @param	p_evt	(MouseEvent) click event
		 * @return	void
		 */
		private function _onClick( p_evt:MouseEvent ):void
		{
			if( !scrubber_mc || p_evt.target != scrubber_mc && !isLive )
			{
				//dispatchEvent( new ControlBarEvent( ControlBarEvent.SEEK, 0, ( mouseX - _scrubberPadding ) / _activeRange, true ) );
				seeked.dispatch(( mouseX - _scrubberPadding ) / _activeRange);
			}
		}
		
		/**
		 * Start draggin the scrubber when the mouse is down on the scrubber.
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onScrubberMouseDown( p_evt:MouseEvent ):void
		{
			_dragging = true;
			
			scrubber_mc.addEventListener( MouseEvent.MOUSE_MOVE, _onScrubberMouseMove );
			
			stage.addEventListener( MouseEvent.MOUSE_UP, _onStageMouseUp );
			
			scrubber_mc.startDrag( false, new Rectangle( 0, scrubber_mc.y, _activeRange, 0 ) );
		}
		
		/**
		 * Stop dragging the scrubber
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onScrubberMouseUp( p_evt:MouseEvent ):void
		{
			_stopScrubberDrag();
		}
		
		/**
		 * Change the width of the progress bar to match movements of the
		 * scrubber when it is being dragged.
		 * 
		 * @param	p_evt	(MouseEvent) mouse move event
		 * @return	void
		 */
		private function _onScrubberMouseMove( p_evt:MouseEvent ):void
		{
			current_mc.width = scrubber_mc.x + _scrubberPadding;
		}
		
		/**
		 * Stop dragging the scrubber
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onStageMouseUp( p_evt:MouseEvent ):void
		{
			_stopScrubberDrag();
		}
		
		
		
	}
}