package thanhtran.karaokeplayer.audio {
	import org.osflash.signals.Signal;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import thanhtran.karaokeplayer.Version;
	import flash.media.Sound;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class BeatPlayer extends Sprite {
		public static const VERSION: String = Version.VERSION;
		
		public var audioCompleted: Signal;
		
		private var _sound: Sound;
		private var _channel: SoundChannel; 
		
		public function BeatPlayer() {
			audioCompleted = new Signal();	
		}

		public function init(sound: Sound): void {
			_sound = sound;	
		}
		
		/**
		 *  
		 */
		public function play(): void {
			if(_channel) {
				_channel.stop();			
			}
			_channel = _sound.play();
			_channel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		}

		private function soundCompleteHandler(event: Event): void {
			audioCompleted.dispatch();
		}
		
		public function get position(): Number {
			if(_channel) return _channel.position;
			else return 0;
		}
		
		public function get length(): Number {
			return _sound.length;
		}
	}
}
