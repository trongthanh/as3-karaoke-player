package vn.karaokeplayer.lyricseditor.controls {
	import vn.karaokeplayer.utils.TimeUtil;

	import org.osflash.signals.Signal;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**
	 * @author Thanh Tran
	 */	 
	[Embed(source="/../assets/swc/controls_ui.swf", symbol="vn.karaokeplayer.lyricseditor.ui.TimeDisplayUI")]
	public class TimeDisplay extends Sprite {
	//stage
		public var min: TextField;
		public var sec: TextField;
		public var millis: TextField;
		
		//signals	
		/**
		 * Argument: time value (uint)
		 */
		public var changed: Signal;
		
		//private props
		private var _timeValue: uint;
		
		public function TimeDisplay() {			
			init();
		}

		private function init(): void {
			//must reset the text or the selection action cause bug
			min.text = "00";
			sec.text = "00";
			millis.text = "000";
			
			min.restrict = "0-9";
			sec.restrict = "0-9";
			millis.restrict = "0-9";
			
			min.addEventListener(MouseEvent.MOUSE_DOWN, textFieldFocusInHandler);
			sec.addEventListener(MouseEvent.MOUSE_DOWN, textFieldFocusInHandler);
			millis.addEventListener(MouseEvent.MOUSE_DOWN, textFieldFocusInHandler);
			
			min.addEventListener(FocusEvent.FOCUS_OUT, textFocusOutHandler);			sec.addEventListener(FocusEvent.FOCUS_OUT, textFocusOutHandler);			millis.addEventListener(FocusEvent.FOCUS_OUT, textFocusOutHandler);
			
			min.addEventListener(Event.CHANGE, textChangeHandler);
			sec.addEventListener(Event.CHANGE, textChangeHandler);
			millis.addEventListener(Event.CHANGE, textChangeHandler);
			
			changed = new Signal(uint);
		}

		private function textFocusOutHandler(event: FocusEvent): void {
			//trace("focus out " + event.target);
			var tf: TextField = event.target as TextField;
			if(tf == millis) {
				tf.text = TimeUtil.fillZeroes(tf.text, 3);	
			} else {
				tf.text = TimeUtil.fillZeroes(tf.text, 2);
			}
			
		}

		private function textChangeHandler(event: Event): void {
			_timeValue = (minValue * 60 + secValue) * 1000 + msValue;
			changed.dispatch(_timeValue);
		}

		private function textFieldFocusInHandler(event: MouseEvent): void {
			
			var targetText: TextField = event.currentTarget as TextField;
			
			targetText.setSelection(0, targetText.length);
		}
		
		public function get minValue(): uint {
			return uint(min.text);
		}
		
		public function get secValue(): uint {
			return uint(sec.text);
		}
		
		public function get msValue(): uint {
			return uint(millis.text);
		}
		
		public function set timeValue(value: uint): void {
			if(_timeValue != value) {
				_timeValue = value;
				updateText();
				//changed.dispatch(_timeValue);					
			}
		}
		
		public function get timeValue(): uint {
			return _timeValue;
		}
		
		private function updateText(): void {
			var ms: String = String(timeValue % 1000);
			var remain: uint = uint(timeValue / 1000);
			var s: String = String(remain % 60);
			remain = uint(remain / 60);
			var m: String = String(remain % 60);
			//var h: String = String(uint(remain / 60));
			
			min.text = TimeUtil.fillZeroes(m, 2);
			sec.text = TimeUtil.fillZeroes(s, 2);
			millis.text = TimeUtil.fillZeroes(ms, 3);		
		}
	}
}
