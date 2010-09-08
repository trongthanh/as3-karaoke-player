package vn.karaokeplayer.lyricseditor.controls {
	import flash.filters.ColorMatrixFilter;
	import flash.media.SoundTransform;
	import flash.media.SoundMixer;
	import vn.karaokeplayer.utils.EnterFrameManager;
	import vn.karaokeplayer.audio.AudioPlayer;
	import fl.events.SliderEvent;
	import flash.events.MouseEvent;
	import fl.controls.Slider;
	import flash.display.SimpleButton;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[Embed(source="/../assets/swc/controls_ui.swf", symbol="vn.karaokeplayer.lyricseditor.ui.PlayerBarUI")]	
	public class PlayerControlBar extends Sprite {
		//stage
		public var playButton: SimpleButton;
		public var pauseButton: SimpleButton;
		public var stopButton: SimpleButton;
		public var currentTimer: TimeDisplay;
		public var startTimer: TimeDisplay;
		public var seekTimer: TimeDisplay;
		public var timeSlider: Slider;
		public var volumeSlider: Slider;
		
		//props
		private var _audioPlayer: AudioPlayer;
		private var _sliderDragging: Boolean;
		private var _grayFilter: ColorMatrixFilter;
				
		public function PlayerControlBar() {
			
			init();
			
		}
		
		public function open(soundURL: String): void {
			_audioPlayer.open(soundURL);
			enabled = false;
		}

		private function init(): void {
			var _s: Number = 0; //saturation value 0 - 1 - 2
						
			_grayFilter = new ColorMatrixFilter (
			[0.114 + 0.886 * _s,	0.299 * (1 - _s),	0.1 * (1 - _s),	0,	0,
			 0.114 * (1 - _s), 		0.299 + 0.701 * _s,	0.1 * (1 - _s),	0,	0, 
			 0.114 * (1 - _s), 		0.299 * (1 - _s),	0.1 + 0.413 * _s, 0,	0, 					
			 0,						0, 					0, 					1,	0]);
			
//			[0.114 + 0.886 * _s,	0.299 * (1 - _s),	0.587 * (1 - _s),	0,	0,
//			 0.114 * (1 - _s), 		0.299 + 0.701 * _s,	0.587 * (1 - _s),	0,	0, 
//			 0.114 * (1 - _s), 		0.299 * (1 - _s),	0.587 + 0.413 * _s, 0,	0, 					
//			 0,						0, 					0, 					1,	0]);
			
			_audioPlayer = new AudioPlayer();
			_audioPlayer.audioCompleted.add(audioCompleteHandler);
			_audioPlayer.loadCompleted.add(loadCompleteHandler);
			
			timeSlider = new Slider();
			timeSlider.x = 346; //refer from fla
			timeSlider.y = 24;
			timeSlider.width = 350;
			timeSlider.enabled = false;
			
			addChild(timeSlider);
			
			volumeSlider = new Slider();
			volumeSlider.x = 730; //refer from fla
			volumeSlider.y = 24;
			volumeSlider.width = 50;
			volumeSlider.enabled = true;
			volumeSlider.minimum = 0;
			volumeSlider.maximum = 100;
			volumeSlider.value = 100;
			
			addChild(volumeSlider);
			
			seekTimer.visible = false;
			
			playButton.addEventListener(MouseEvent.CLICK, playButtonClickHandler);
			pauseButton.addEventListener(MouseEvent.CLICK, pauseButtonClickHandler);
			stopButton.addEventListener(MouseEvent.CLICK, stopButtonClickHandler);
			currentTimer.changed.add(currentTimerChangeHandler);
			startTimer.changed.add(startTimerChangeHandler);
			volumeSlider.addEventListener(SliderEvent.CHANGE, volumeSliderChangeHandler);
			timeSlider.addEventListener(SliderEvent.CHANGE, timeSliderChangeHandler);
			timeSlider.addEventListener(MouseEvent.MOUSE_DOWN, timeSliderStartDragHandler);
			
			//default disable
			enabled = false;
		}

		private function volumeSliderChangeHandler(event: SliderEvent): void {
			SoundMixer.soundTransform = new SoundTransform(event.value / 100);
		}

		private function timeSliderStartDragHandler(event: MouseEvent): void {
			stage.addEventListener(MouseEvent.MOUSE_UP, timeSliderStopDragHandler);
			EnterFrameManager.instance.enterFrame.add(updateSeekPosition);
			seekTimer.timeValue = timeSlider.value;
			seekTimer.visible = true;			
			_sliderDragging = true;
		}

		private function updateSeekPosition(): void {
			seekTimer.timeValue = timeSlider.value;
		}

		private function timeSliderStopDragHandler(event: MouseEvent): void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, timeSliderStopDragHandler);
			EnterFrameManager.instance.enterFrame.remove(updateSeekPosition);
			seekTimer.visible = false;
			_sliderDragging = false;
		}

		private function loadCompleteHandler(): void {
			trace("audio load complete");
			timeSlider.enabled = true;
			timeSlider.minimum = 0;
			timeSlider.maximum = _audioPlayer.length;
			timeSlider.value = 0;
			enabled = true;
		}

		private function audioCompleteHandler(): void {
			trace("audio complete");
			EnterFrameManager.instance.enterFrame.remove(updateTimePosition);
		}

		private function timeSliderChangeHandler(event: SliderEvent): void {
			trace("slider " + event.value);
			var value: uint = uint(event.value);
			currentTimer.timeValue = value;
			_audioPlayer.seek(value);	
		}

		private function currentTimerChangeHandler(timeValue: uint): void {
			if(_audioPlayer.seek(timeValue)) {
				timeSlider.value = timeValue;
			} else {
				currentTimer.timeValue = timeSlider.value;
			}
		}
		
		private function startTimerChangeHandler(timeValue: uint): void {
			
		}

		private function pauseButtonClickHandler(event: MouseEvent): void {
			trace('pauseButtonClickHandler: ');
			if(_audioPlayer.pausing) return;
			EnterFrameManager.instance.enterFrame.remove(updateTimePosition);
			_audioPlayer.pause();	
		}

		private function playButtonClickHandler(event: MouseEvent): void {
			trace('playButtonClickHandler: ');
			
			if(!_audioPlayer.pausing && _audioPlayer.playing) return;
			EnterFrameManager.instance.enterFrame.add(updateTimePosition);
			if(!_audioPlayer.playing) {
				_audioPlayer.play(startTimer.timeValue);
			} else {
				_audioPlayer.play();
			}
		}
		
		private function stopButtonClickHandler(event: MouseEvent): void {
			EnterFrameManager.instance.enterFrame.remove(updateTimePosition);
			_audioPlayer.stop();
			timeSlider.value = startTimer.timeValue;
			currentTimer.timeValue = startTimer.timeValue;
		}

		private function updateTimePosition(): void {
			var pos: Number = _audioPlayer.position;
			currentTimer.timeValue = pos;
			if(!_sliderDragging) timeSlider.value = pos;
		}
		
		public function set enabled(value: Boolean): void {
			mouseChildren = value;
			if(value) {
				this.filters = null;
			} else {
				this.filters = [_grayFilter];
			}
		}
		
		public function get enabled(): Boolean {
			return mouseChildren;
		}
	}
}
