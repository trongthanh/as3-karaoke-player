package thanhtran.karaokeplayer.audio {
	import org.osflash.signals.Signal;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import thanhtran.karaokeplayer.Version;
	import flash.media.Sound;

	/**
	 * @author Thanh Tran
	 */
	public class BeatPlayer {
		public static const VERSION: String = Version.VERSION;
		
		public var audioCompleted: Signal;
		
		private var _sound: Sound;
		private var _channel: SoundChannel; 
		private var _position: Number;
		private var _playing: Boolean;
		private var _pausing: Boolean;
		
		public function BeatPlayer() {
			audioCompleted = new Signal();	
		}

		public function init(sound: Sound): void {
			_sound = sound;	
		}
		
		/**
		 *  play the beat
		 */
		public function play(startTime: Number = 0): void {
			if(_channel) {
				_channel.stop();			
			}
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
			if (_channel) { 
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_channel = null;
			}
			_pausing = true;
		}
		
		public function stop(): void {
			if (_channel) { 
				_channel.stop();
				_channel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
				_channel = null;
			}
			
			_playing = false;
			_pausing = false;
			_position = 0;
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
			return _sound.length;
		}
	}
}
