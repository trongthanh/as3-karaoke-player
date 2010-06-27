package vn.karaokeplayer.utils {
	import org.osflash.signals.Signal;

	/**
	 * @author Thanh Tran
	 */
	public class Timer {
		
		private var _completed: Signal;
		private var _ticked: Signal;
		
		private var _delay: int;
		private var _repeat: int;
		
		/**
		 * 
		 */
		public function Timer(delay: int, repeat: int = 0) {
			_delay = delay;
			_repeat = repeat;
			_completed = new Signal();
			_ticked = new Signal();
		}

		public function get completed(): Signal {
			return _completed;
		}
		
		public function get ticked(): Signal {
			return _ticked;
		}
	}
}
