package com.realeyes.osmfplayer.controls
{
	import com.realeyes.osmfplayer.util.ControlBarItemVO;
	import org.osflash.signals.Signal;
	//import com.realeyes.osmfplayer.events.ControlBarEvent;
	//import com.realeyes.osmfplayer.events.RollOutToleranceEvent;
	//import com.realeyes.osmfplayer.events.ToggleButtonEvent;
	//import com.realeyes.osmfplayer.model.layout.ControlBarItemVO;
	import com.realeyes.osmfplayer.util.RollOutTolerance;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * Displays controls for the associated player. 
	 * 
	 * @author	RealEyes Media
	 * @author	Thanh Tran
	 * @version	1.0
	 */
	public class ControlBar extends SkinElementBase implements IControlBar
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		public var played: Signal;
		public var paused: Signal;
		public var stopped: Signal;
		public var muted: Signal;
		public var unmuted: Signal;
		public var fullScreen: Signal;
		public var restored: Signal;
		
		public var bg_mc:MovieClip;
		
		public var play_mc:ToggleButton;
		public var pause_mc:ToggleButton;
		public var playPause_mc:ToggleButton;
		public var volume_mc:ToggleButton;
		public var fullScreen_mc:ToggleButton;
		public var closedCaption_mc:ToggleButton;
		
		public var stop_mc:ToggleButton;
		public var volumeUp_mc:ToggleButton;
		public var volumeDown_mc:ToggleButton;
		
		public var bitrateUp_mc:ToggleButton;
		public var bitrateDown_mc:ToggleButton;
				
		public var progress_mc:ProgressBar;
		
		public var divider_mc:MovieClip;
		
		public var volumeSlider_mc:VolumeSlider;
		
		public var currentTime_txt:TextField;
		public var totalTime_txt:TextField;
		
		public var displayVolumeSliderBelow:Boolean = false;
		
		private var _currentState:String;
		
		public var draggable:Boolean = true;

		private var _volumeSliderRolloutTolerance:RollOutTolerance;
		private var _isLive:Boolean;
		private var _hasCaptions:Boolean;
		private var _autoHideVolume:Boolean = true;
		
		private var _currentTime:Number;
		private var _duration:Number;
		
		// Added to account for settings in the config using the <element> sub-nodes in <skin>
		private var _autoHide:Boolean;
		//protected var _controlsItemList:Vector.<ControlBarItemVO>;
		protected var _controlsItemList: Array;
		
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const BOTH:String = "both";
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function ControlBar()
		{
			super();
			
			played = new Signal(Signal); //return the signal itself so handling function know which signal is dispatching
			paused = new Signal(Signal);
			stopped = new Signal(Signal);
			muted = new Signal(Signal, Boolean);
			//unmuted = new Signal(Signal);
			fullScreen = new Signal(Signal, Boolean);
			//restored = new Signal(Signal);
			
			if( _autoHideVolume )
			{
				_volumeSliderRolloutTolerance = new RollOutTolerance( volumeSlider_mc, volume_mc );
			}
			
			_checkControls();
			
			if( displayVolumeSliderBelow )
			{
				volumeSlider_mc.y += volumeSlider_mc.height + volume_mc.height;
				//volumeSlider_mc.displayBelow = true;
			}
			
			if( currentTime_txt )
			{
				currentTime_txt.mouseEnabled = false;
			}
			
			if( totalTime_txt )
			{
				totalTime_txt.mouseEnabled = false;
			}
		}
		
		
		/////////////////////////////////////////////
		//  INIT METHODS
		/////////////////////////////////////////////
		/**
		 * Creates listeners for each of the controls that are present.
		 * 
		 * @return	void
		 */
		protected function _checkControls():void
		{
			
			if( play_mc )
			{
				_initPlayButton();
			}
			
			if( pause_mc )
			{
				_initPauseButton();
				
			}
			
			if( stop_mc )
			{
				_initStopButton();
			}
			
			if( volumeUp_mc )
			{
				_initVolumeUpButton();
			}
			
			if( volumeDown_mc )
			{
				_initVolumeDownButton();
			}
			
			
			if(playPause_mc)
			{
				_initPlayPauseButton();
			}
			
			if(volume_mc)
			{
				_initVolumeButton();
			}
			
			if( volumeSlider_mc )
			{
				_initVolumeSlider();
			}
			
			if(fullScreen_mc)
			{
				_initFullScreenButton();
			}
			
			if(closedCaption_mc)
			{
				_initClosedCaptionButton();
			}
			
			if(bitrateUp_mc)
			{
				_initBitrateUpButton();
			}
			
			if(bitrateDown_mc)
			{
				_initBitrateDownButton();
			}
			
			if(bg_mc)
			{
				_initBG();
			}
			
			if( _autoHideVolume )
			{
				//_volumeSliderRolloutTolerance.addEventListener( RollOutToleranceEvent.TOLERANCE_OUT, _onVolumeSliderTolleranceOut );
				_volumeSliderRolloutTolerance.toleranceOut.add(_onVolumeSliderTolleranceOut);
			}
			
			if( progress_mc )
			{
				_initProgressBar();
			}
			
			if( currentTime_txt )
			{ 
				_initCurrentTimeText();
			}
			
			if( totalTime_txt )
			{
				_initTotalTimeText();
			}
			
			if( divider_mc )
			{
				_initDivider();
			}
		}
		
		
		protected function _initPlayButton():void
		{
			play_mc.toggle = false;
			//play_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPlayClick );
			play_mc.clicked.add(_onPlayClick);
			_addControlItem( play_mc );
		}
		
		protected function _initPauseButton():void
		{
			pause_mc.toggle = false;
			//pause_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPauseClick );
			pause_mc.clicked.add(_onPauseClick);
			_addControlItem( pause_mc );
		}
		
		protected function _initStopButton():void
		{
			stop_mc.toggle = false;
			//stop_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onStopClick );
			stop_mc.clicked.add(_onStopClick);
			_addControlItem( stop_mc );
		}
		
		protected function _initVolumeUpButton():void
		{
			volumeUp_mc.toggle = false;
			//volumeUp_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeUpClick );
			volumeUp_mc.clicked.add(_onVolumeUpClick);
			_addControlItem( volumeUp_mc );
		}
		
		protected function _initVolumeDownButton():void
		{
			volumeDown_mc.toggle = false;
			//volumeDown_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeDownClick );
			volumeDown_mc.clicked.add(_onVolumeDownClick);
			_addControlItem( volumeDown_mc );
		}
		
		protected function _initPlayPauseButton():void
		{
			//playPause_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onPlayPauseClick );
			playPause_mc.clicked.add(_onPlayPauseClick);
			_addControlItem( playPause_mc );
		}
		
		protected function _initVolumeButton():void
		{
			//volume_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onVolumeClick );
			volume_mc.clicked.add(_onVolumeClick);
			//volume_mc.addEventListener( MouseEvent.MOUSE_OVER, _onVolumeOver );
			volume_mc.rollOver.add(_onVolumeOver);
			//volume_mc.addEventListener( MouseEvent.MOUSE_OUT, _onVolumeOut );
			volume_mc.rollOut.add(_onVolumeOut);
			_addControlItem( volume_mc );
		}
		
		protected function _initVolumeSlider():void
		{
			_addControlItem( volumeSlider_mc );
		}
		
		protected function _initFullScreenButton():void
		{
			//fullScreen_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onfullScreenClick );
			fullScreen_mc.clicked.add(_onfullScreenClick);
			_addControlItem( fullScreen_mc );
		}
		
		protected function _initClosedCaptionButton():void
		{
			//closedCaption_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onClosedCaptionClick );
			closedCaption_mc.clicked.add(_onClosedCaptionClick);
			_addControlItem( closedCaption_mc );
		}
		
		protected function _initBitrateUpButton():void
		{
			bitrateUp_mc.toggle = false;
			//bitrateUp_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onBitrateUpClick );
			bitrateUp_mc.clicked.add(_onBitrateUpClick);
			_addControlItem( bitrateUp_mc );
		}
		
		
		protected function _initBitrateDownButton():void
		{
			bitrateDown_mc.toggle = false;
			//bitrateDown_mc.addEventListener( ToggleButtonEvent.TOGGLE_BUTTON_CLICK, _onBitrateDownClick );
			bitrateDown_mc.clicked.add(_onBitrateDownClick);
			_addControlItem( bitrateDown_mc );
		}
		
		protected function _initBG():void
		{
			bg_mc.addEventListener( MouseEvent.MOUSE_DOWN, _onBGDown );
			bg_mc.addEventListener( MouseEvent.MOUSE_UP, _onBGUp );
		}
		
		protected function _initProgressBar():void
		{
			_addControlItem( progress_mc );
		}
		
		protected function _initCurrentTimeText():void
		{
			_addControlItem( currentTime_txt );
		}
		
		protected function _initTotalTimeText():void
		{
			_addControlItem( totalTime_txt );
		}
		
		protected function _initDivider():void
		{
			_addControlItem( divider_mc );
		}
		
		/////////////////////////////////////////////
		//  CONTROL/METHODS
		/////////////////////////////////////////////
		
		protected function _addControlItem( p_item:DisplayObject ):void
		{
			var anchor:String;
			var left:Number;
			var right:Number;
			
			if( p_item is ISkinSprite && (p_item as ISkinSprite).anchor )
			{
				anchor = (p_item as ISkinSprite).anchor;
			}
			
			if( !anchor )
			{
				if( p_item.x <= this.width / 2 )
				{
					anchor = LEFT;
				}
				else
				{
					anchor = RIGHT;
				}
			}
			
			
			left = p_item.x;
			right = this.width - ( p_item.x + p_item.width );
			
			
			
			if( !_controlsItemList )
			{
				_controlsItemList = new Array();
			}
			
			_controlsItemList.push( new ControlBarItemVO( p_item, anchor, left, right ) );
		}
		
		
		public function _updateLayout():void
		{
			if( _controlsItemList && _controlsItemList.length )
			{
				for each( var vo:ControlBarItemVO in _controlsItemList )
				{
					_updateItemPosition( vo );
				}
				
				//_controlsItemList.forEach( _updateItemPosition );
			}
		}
		
		public function _updateItemPosition( p_item:ControlBarItemVO ):void
		{
			switch( p_item.anchor )
			{
				case LEFT:
				{
					p_item.target.x = p_item.left;
					break;
				}
				
				case RIGHT:
				{
					p_item.target.x = width - p_item.target.width - p_item.right;
					break;
				}
					
				case BOTH:
				{
					p_item.target.x = p_item.left;
					p_item.target.width = width - p_item.right - p_item.left;
					break;
				}
			}
			
			
		}
		
		
		/**
		 * Takes a number of seconds and returns it in the format
		 * of M:SS.
		 * 
		 * @param	p_time	(Number) the time in seconds
		 * @return	String
		 */
		protected function formatSecondsToString( p_time:Number ):String
		{
			var min:Number = Math.floor( p_time / 60 );
			var sec:Number = p_time % 60;
			
			return min + ":" + ( sec.toString().length < 2 ? "0" + sec : sec );
		}
		
		/**
		 * Sets the percentage of the current progress indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		public function setCurrentBarPercent( p_value:Number ):void
		{
			if( progress_mc )
			{
				progress_mc.setCurrentBarPercent( p_value );
			}
			
		}
		
		/**
		 * Sets the percentage of the loading indicator to the given
		 * percentage of the progress bar
		 * 
		 * @param	p_value	(Number) percentage of the bar to set the progress indicator at
		 * @return	void
		 */
		public function setLoadBarPercent( p_value:Number ):void
		{
			if( progress_mc )
			{
				progress_mc.setLoadBarPercent( p_value );
			}
		}
		
		/**
		 * Enables manual selection of a higher bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		public function bitrateUpEnabled():void
		{
			if( bitrateUp_mc )
			{
				bitrateUp_mc.enabled = true;
			}
		}
		
		/**
		 * Enables manual selection of a lower bitrate stream, if it exists
		 * 
		 * @return	void
		 */
		public function bitrateDownEnabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateDown_mc.enabled = true;
			}
		}
		
		/**
		 * Disables manual selection of a higher bitrate stream
		 * 
		 * @return	void
		 */
		public function bitrateUpDisabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateUp_mc.enabled = false;
			}
		}
		
		
		/**
		 * Disables manual selection of a lower bitrate stream
		 * 
		 * @return	void
		 */
		public function bitrateDownDisabled():void
		{
			if( bitrateDown_mc )
			{
				bitrateDown_mc.enabled = false;
			}
		}
		
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		public function get autoHide():Boolean
		{
			return _autoHide;
		}
		
		public function set autoHide(value:Boolean):void
		{
			_autoHide = value;
		}
		
		/**
		 * height
		 * Height of the background or the containing clip
		 * @return	Number
		 */
		override public function get height():Number
		{
			if( bg_mc )
			{
				return bg_mc.height;
			}
				
			return super.height;
			
		}
		
		override public function get width():Number
		{
			if( bg_mc )
			{
				return bg_mc.width;
			}
				
			return super.width;
			
		}
		
		override public function set width( p_value:Number):void
		{
			if( bg_mc )
			{
				bg_mc.width = p_value;
				_updateLayout();
				
				return;
			}
				
			super.width = p_value;
		}
		
		
		/**
		 * isLive
		 * Is the media playing live?
		 * @return	Boolean
		 */
		public function get isLive():Boolean
		{
			return _isLive;
		}
		
		public function set isLive( p_value:Boolean ):void
		{
			_isLive = p_value;
			
			if( progress_mc )
			{
				progress_mc.isLive = _isLive;
			}
		}
		
		/**
		 * currentTime
		 * The current time in seconds.
		 * @return	Number
		 */
		public function get currentTime():Number
		{
			return _currentTime;
		}
		
		public function set currentTime( p_value:Number ):void
		{
			_currentTime = p_value;
			if( currentTime_txt )
			{
				currentTime_txt.text = formatSecondsToString( p_value );
			}
			
		}
		
		/**
		 * duration
		 * The length of the media in seconds.
		 * @return	Number
		 */
		public function get duration():Number
		{
			return _duration;
		}
		
		public function set duration( p_value:Number ):void
		{
			_duration = p_value;
			if( totalTime_txt )
			{
				totalTime_txt.text = formatSecondsToString( p_value );
			}
		}
		
		/**
		 * currentState
		 * The current state. Options include: 'stopped', 'paused', and 'playing'
		 * @return	String
		 */
		public function get currentState():String
		{
			return _currentState;
		}
		
		public function set currentState( p_value:String ):void
		{
			_currentState = p_value;
			
			
			
			switch( _currentState )
			{
				case "stopped" :
				case "paused" :
				{
					
					if( playPause_mc && !playPause_mc.selected)
					{
						playPause_mc.selected = true;
					}
					
					break;
				}
				case "playing" :
				{
					
					if( playPause_mc && playPause_mc.selected)
					{
						playPause_mc.selected = false;
					}
					break;
				}
			}
			
		}
		
		
		/**
		 * hasCaptions	
		 * Should the control enable the closed caption controls if they exist
		 * @return	Boolean
		 */
		public function get hasCaptions():Boolean
		{
			return _hasCaptions;
		}
		
		public function set hasCaptions( p_value:Boolean ):void
		{
			_hasCaptions = p_value;
			
			if( closedCaption_mc )
			{
				closedCaption_mc.enabled = _hasCaptions;
			}
		}
		
		public function get autoHideVolume():Boolean
		{
			return _autoHideVolume;
		}
		public function set autoHideVolume( value:Boolean ):void
		{
			_autoHideVolume = value;
		}
		
		
		
		/////////////////////////////////////////////
		//  HANDLERS
		/////////////////////////////////////////////
		/**
		 * Dispatches ControlBarEvent.PLAY when Play button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPlayClick( /*p_evt:ToggleButtonEvent*/ ):void
		{
			//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PLAY ) );
			played.dispatch(played);				
		}
		
		/**
		 * Dispatches ControlBarEvent.PAUSE when Pause button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPauseClick( /*p_evt:ToggleButtonEvent*/ ):void
		{
			//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.PAUSE ) );
			paused.dispatch(paused);
		}
		
		/**
		 * Dispatches ControlBarEvent.PLAY or ControlBarEvent.PAUSE when 
		 * Pause/Play button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onPlayPauseClick( /*p_evt:ToggleButtonEvent*/selected: Boolean ):void
		{
			if( selected)
			{
				//trace("disp - PAUSE");
				_onPauseClick(/* p_evt*/ );
			}
			else
			{
				//trace("disp - PLAY");
				_onPlayClick( /*p_evt*/ );
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.MUTE or ControlBarEvent.UNMUTE when 
		 * the Volume button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeClick( /*p_evt:ToggleButtonEvent*/selected: Boolean ):void
		{
			muted.dispatch(muted, selected);
			if( selected)
			{
				//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.MUTE ) );
				
			}
			else
			{
				//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.UNMUTE ) );
			}
		}
		
		
		/**
		 * Display the volume slider when rolled over
		 * 
		 * @param	p_evt	(MouseEvent) Mouse Over event
		 * @return	void
		 */
		private function _onVolumeOver( p_evt:MouseEvent ):void
		{
			volumeSlider_mc.visible = true;
		}
		
		
		/**
		 * Hide the volume slider when rolled over
		 * 
		 * @param	p_evt	(MouseEvent) Mouse Out event
		 * @return	void
		 */
		private function _onVolumeOut( p_evt:MouseEvent ):void
		{
			_volumeSliderRolloutTolerance.start();
		}
		
		
		
		/**
		 * Dispatches ControlBarEvent.FULLSCREEN or ControlBarEvent.FULLSCREEN_RETURN 
		 * when the fullscreen button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onfullScreenClick( /*p_evt:ToggleButtonEvent*/selected: Boolean ):void 
		{
			fullScreen.dispatch(fullScreen, selected);
			if( selected)
			{
				//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.FULLSCREEN ) );
				
				stage.addEventListener( FullScreenEvent.FULL_SCREEN, _onFullScreen );
			}
			else
			{
				//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.FULLSCREEN_RETURN ) );
			}
		}
		
		/**
		 * When the player returns to normal from fullscreen mode, make sure the fullscreen
		 * button gets updated
		 * 
		 * @param	p_evt	(FullScreenEvent)
		 * @return	void
		 */
		private function _onFullScreen( p_evt:FullScreenEvent ):void
		{
			if( stage.displayState == StageDisplayState.NORMAL && fullScreen_mc.selected )
			{
				fullScreen_mc.selected = false;
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.SHOW_CLOSEDCAPTION or ControlBarEvent.HIDE_CLOSEDCAPTION 
		 * when the closed caption button is toggled
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onClosedCaptionClick( /*p_evt:ToggleButtonEvent*/selected: Boolean ):void
		{
			if( selected)
			{
				//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.SHOW_CLOSEDCAPTION ) );
			}
			else
			{
				//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.HIDE_CLOSEDCAPTION ) );
			}
		}
		
		/**
		 * For draggable control bars, starts the dragging when the
		 * BG is clicked on.
		 * 
		 * @param	p_evt	(MouseEvent) mouse down event
		 * @return	void
		 */
		private function _onBGDown( p_evt:MouseEvent ):void
		{
			if( draggable )
			{
				this.startDrag();
			}
		}
		
		/**
		 * For draggable control bars, ends the dragging when the
		 * BG is released.
		 * 
		 * @param	p_evt	(MouseEvent) mouse up event
		 * @return	void
		 */
		private function _onBGUp( p_evt:MouseEvent ):void
		{
			if( draggable )
			{
				this.stopDrag();				
			}
		}
		
		
		/**
		 * Dispatches ControlBarEvent.STOP when Stop button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onStopClick( /*p_evt:ToggleButtonEvent*/ ):void
		{
			//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.STOP ) );
			
		}

		/**
		 * Hide the volume slider when rolled out from.
		 * 
		 * @param	p_evt	(RollOutToleranceEvent)
		 * @return	void
		 */
		protected function _onVolumeSliderTolleranceOut( /*p_evt:RollOutToleranceEvent*/ ):void
		{
			if( _autoHideVolume )
			{
				volumeSlider_mc.visible = false;
			}
			else
			{
				//_volumeSliderRolloutTolerance.removeEventListener( RollOutToleranceEvent.TOLERANCE_OUT, _onVolumeSliderTolleranceOut );
				_volumeSliderRolloutTolerance.toleranceOut.remove(_onVolumeSliderTolleranceOut);
			}
		}
		
		/**
		 * Dispatches ControlBarEvent.VOLUME_UP when Volume Up button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeUpClick( /*p_evt:ToggleButtonEvent*/ ):void
		{
			//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME_UP ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.VOLUME_DOWN when Volume Down button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onVolumeDownClick( /*p_evt:ToggleButtonEvent*/ ):void
		{
			//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.VOLUME_DOWN ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.BITRATE_UP when Bitrate Up button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */
		private function _onBitrateUpClick(/* p_evt:ToggleButtonEvent*/ ):void
		{
			//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.BITRATE_UP ) );
		}
		
		/**
		 * Dispatches ControlBarEvent.BITRATE_DOWN when Bitrate Down button is clicked
		 * 
		 * @param	p_evt	(ToggleButtonEvent) click event
		 * @return	void
		 */

		private function _onBitrateDownClick( /*p_evt:ToggleButtonEvent */):void
		{
			//this.dispatchEvent( new ControlBarEvent( ControlBarEvent.BITRATE_DOWN ) );
		}
	
		
	}
}

