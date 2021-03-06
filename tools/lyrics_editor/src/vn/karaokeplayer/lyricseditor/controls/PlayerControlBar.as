package vn.karaokeplayer.lyricseditor.controls {
	import org.osflash.signals.Signal;
	import fl.controls.Slider;
	import fl.events.SliderEvent;

	import vn.karaokeplayer.KarPlayer;
	import vn.karaokeplayer.data.KarPlayerOptions;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.lyricseditor.utils.DisplayObjectUtil;
	import vn.karaokeplayer.utils.EnterFrameManager;

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;

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
		private var _karPlayer: KarPlayer;
		private var _sliderDragging: Boolean;
		
		/**
		 * Dispatch when audio is loaded and ready for play back
		 */
		public var playerReady: Signal;
				
		public function PlayerControlBar() {
			
			init();
			
		}
		
		public function open(songInfo: SongInfo): void {
			_karPlayer.loadSong(songInfo);
			//_karPlayer.open(soundURL);
			enabled = false;
		}

		private function init(): void {			
			var playerOptions: KarPlayerOptions = new KarPlayerOptions();
			playerOptions.width = 600;
			playerOptions.height = 450;
			
			_karPlayer = new KarPlayer(playerOptions);
			_karPlayer.audioCompleted.add(audioCompleteHandler);
			_karPlayer.loadCompleted.add(loadCompleteHandler);
			
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
			
			ToolTip.attach(playButton, "Play audio from current position");
			ToolTip.attach(pauseButton, "Pause audio");
			ToolTip.attach(stopButton, "Stop playing audio and <br/>reset current position to start time");
			
			playerReady = new Signal();
			
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
			timeSlider.maximum = _karPlayer.length;
			timeSlider.value = 0;
			enabled = true;
			playerReady.dispatch();
		}

		private function audioCompleteHandler(): void {
			trace("audio complete");
			EnterFrameManager.instance.enterFrame.remove(updateTimePosition);
		}

		private function timeSliderChangeHandler(event: SliderEvent): void {
			trace("slider " + event.value);
			var value: uint = uint(event.value);
			currentTimer.timeValue = value;
			_karPlayer.seek(value);	
		}

		private function currentTimerChangeHandler(timeValue: uint): void {
			if(_karPlayer.seek(timeValue)) {
				timeSlider.value = timeValue;
			} else {
				currentTimer.timeValue = timeSlider.value;
			}
		}
		
		private function startTimerChangeHandler(timeValue: uint): void {
			
		}

		private function pauseButtonClickHandler(event: MouseEvent): void {
			trace('pauseButtonClickHandler: ');
			if(_karPlayer.pausing) return;
			EnterFrameManager.instance.enterFrame.remove(updateTimePosition);
			_karPlayer.pause();	
		}

		private function playButtonClickHandler(event: MouseEvent): void {
			trace('playButtonClickHandler: ');
			
			if(!_karPlayer.pausing && _karPlayer.playing) return;
			EnterFrameManager.instance.enterFrame.add(updateTimePosition);
			if(!_karPlayer.playing) {
				_karPlayer.play(startTimer.timeValue);
				//_karPlayer.seek(startTimer.timeValue)
			} else {
				_karPlayer.play();
			}
		}
		
		private function stopButtonClickHandler(event: MouseEvent): void {
			EnterFrameManager.instance.enterFrame.remove(updateTimePosition);
			_karPlayer.stop();
			timeSlider.value = startTimer.timeValue;
			currentTimer.timeValue = startTimer.timeValue;
		}

		private function updateTimePosition(): void {
			var pos: Number = _karPlayer.position;
			currentTimer.timeValue = pos;
			if(!_sliderDragging) timeSlider.value = pos;
		}
		
		public function set enabled(value: Boolean): void {
			if(value) {
				DisplayObjectUtil.enableControl(this);
			} else {
				DisplayObjectUtil.disableControl(this);
			}
		}
		
		public function get enabled(): Boolean {
			return mouseChildren;
		}
		
		public function get karPlayer(): KarPlayer {
			return _karPlayer;
		}
	}
}
