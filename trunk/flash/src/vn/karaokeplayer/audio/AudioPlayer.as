package vn.karaokeplayer.audio {
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.media.SoundLoaderContext;
	import org.osflash.signals.Signal;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import vn.karaokeplayer.Version;
	import flash.media.Sound;

	/**
	 * @author Thanh Tran
	 */
	public class AudioPlayer {
		public static const VERSION: String = Version.VERSION;
		
		public var audioCompleted: Signal;
		public var ready: Signal;
		public var loadProgress: Signal;
		public var loadCompleted: Signal;
		
		private var _sound: Sound;
		private var _channel: SoundChannel;
		private var _position: Number;
		private var _playing: Boolean;
		private var _pausing: Boolean;
		private var _soundOpened: Boolean;
		private var _autoPlay: Boolean;
		private var _bytesLoaded: uint;
		private var _bytesTotal: uint;
		private var _estDur: uint;
		
		public function AudioPlayer() {
			audioCompleted = new Signal();
			ready = new Signal();
			loadProgress = new Signal(uint, uint);
			loadCompleted = new Signal();
		}
		
		/**
		 * TODO: create test case to test this flow
		 */
		public function init(sound: Sound): void {
			_sound = sound;
			_soundOpened = true;
		}

		public function open(soundURL: String): void {
			var request:URLRequest = new URLRequest(soundURL);
			_sound = new Sound();
			_sound.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_sound.addEventListener(Event.OPEN, soundOpenHandler);
			_sound.addEventListener(ProgressEvent.PROGRESS, loadProgressHandler);
			_sound.addEventListener(Event.COMPLETE, loadCompleteHandler);
			//_sound.addEventListener(Event.ID3, id3Handler);
			//IMPORTANT: must turn on checkPolicyFile flag in the SoundLoaderContext for crossdomain ID3 and spectrum process
			_sound.load(request, new SoundLoaderContext(1000, true));
			
			if (_soundOpened) {
				_soundOpened = false;
				stop();
			}
		}

		private function loadCompleteHandler(event: Event): void {
			loadCompleted.dispatch();
		}

		private function loadProgressHandler(event: ProgressEvent): void {
			checkSoundStatus();
			loadProgress.dispatch(_bytesLoaded, _bytesTotal);
		}

		private function ioErrorHandler(event: IOErrorEvent): void {
		}

		private function soundOpenHandler(event: Event): void {
			_soundOpened = true;
			ready.dispatch();
			if(_autoPlay) play();
		}

		/**
		 *  play the beat
		 */
		public function play(startTime: Number = 0): void {
			disposeOfChannel();
			if(!_playing) {
				_position = startTime;	
			}
			_channel = _sound.play(_position);
			_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			_playing = true;
			_pausing = false;
		}
		
		public function pause(): void {
			_position = _channel.position;
			disposeOfChannel();
			_pausing = true;
		}
		
		public function stop(): void {
			disposeOfChannel();
			
			_playing = false;
			_pausing = false;
			_position = 0;
		}
		
		public function seek(pos: Number): Boolean {
			if(pos > _sound.length)  {
				return false;
			} else {
				disposeOfChannel();
				_position = pos;
				if (!_pausing && _playing) {
					//continue playing, need to reassign
					_channel = _sound.play(pos);
					_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);	
				}	
				return true;
			}
		}
		
		/**
		 * Check play and load status of current sound
		 */
		private function checkSoundStatus(): void {
			var s: Sound = _sound;
			var ch: SoundChannel = _channel;
			
			_bytesLoaded = s.bytesLoaded;
			_bytesTotal = s.bytesTotal;
			//var loadPercent: Number = _bytesLoaded / _bytesTotal;
			//length in millisecond of the loaded parts ONLY:
			var duration: Number = s.length;
			//estimate the full length of the song:
			_estDur = duration * _bytesTotal / _bytesLoaded;

			
			
			//if (!_playing || _pausing ) return; //avoid error
			//_position = ch.position;
			//var playPercent: Number = _position / _estDur;
			/*if (playPercent >= 1) {
				trace("Stop");
				stop();
			}*/
			
			
		}
		
		private function disposeOfChannel(): void {
			if (_channel) { 
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_channel = null;
			}
		}

		private function soundCompleteHandler(event: Event): void {
			stop();
			audioCompleted.dispatch();
		}
		
		public function get position(): Number {
			if(_channel) return _channel.position;
			else return _position;
		}

		public function get length(): Number {
			return _estDur;
		}

		public function get playing(): Boolean { return _playing; }
		
		public function get pausing(): Boolean { return _pausing; 
		}
		
		public function get autoPlay(): Boolean {
			return _autoPlay;
		}
		
		public function set autoPlay(autoPlay: Boolean): void {
			_autoPlay = autoPlay;
		}
	}
}
