package vn.karaokeplayer.lyricseditor.controls {
	import vn.karaokeplayer.utils.TimeUtil;

	import org.osflash.signals.Signal;

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;

	/**
	 * @author Thanh Tran
	 */
	[Embed(source="/../assets/swc/controls_ui.swf", symbol="vn.karaokeplayer.lyricseditor.ui.TimeInputUI")]
	public class TimeInput extends Sprite {
		//stage
		public var min: TextField;
		public var sec: TextField;
		public var millis: TextField;
		public var cancelButton: SimpleButton;
		public var okButton: SimpleButton;
		public var resetButton: SimpleButton;
		
		//signals
		/**
		 * Argument: time value (uint)
		 */
		public var committed: Signal;
		
		/**
		 * Argument: time value (uint);
		 */
		public var canceled: Signal;
		
		//private props
		private var _timeValue: uint;
		
		public function TimeInput() {
				
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
			
			min.addEventListener(MouseEvent.MOUSE_DOWN, textFieldFocusInHandler);			sec.addEventListener(MouseEvent.MOUSE_DOWN, textFieldFocusInHandler);			millis.addEventListener(MouseEvent.MOUSE_DOWN, textFieldFocusInHandler);
			
			min.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			sec.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			millis.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			cancelButton.addEventListener(MouseEvent.CLICK, cancelButtonClickHandler);
			okButton.addEventListener(MouseEvent.CLICK, okButtonClickHandler);
			resetButton.addEventListener(MouseEvent.CLICK, resetButtonClickHandler);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			committed = new Signal(uint);
			canceled = new Signal(uint);

		}

		private function mouseDownHandler(event: MouseEvent): void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.startDrag();
		}

		private function mouseUpHandler(event: MouseEvent): void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			this.stopDrag();
		}

		private function keyUpHandler(event: KeyboardEvent): void {
			if(event.keyCode == Keyboard.ENTER) {
				commitValue();
			}else if(event.keyCode == Keyboard.ENTER) {
				cancelValue();
			}
		}
		
		private function resetButtonClickHandler(event: MouseEvent): void {
			updateText();
		}

		private function okButtonClickHandler(event: MouseEvent): void {
			commitValue();
		}

		private function cancelButtonClickHandler(event: MouseEvent): void {
			cancelValue();
		}
		
		private function cancelValue(): void {
			updateText();
			canceled.dispatch(_timeValue);
		}
		
		private function commitValue(): void {
			_timeValue = (minValue * 60 + secValue) * 1000 + msValue;
			committed.dispatch(_timeValue);
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
			_timeValue = value;
			updateText();
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
