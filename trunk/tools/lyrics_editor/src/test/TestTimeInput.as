package test {
	import vn.karaokeplayer.lyricseditor.controls.TimeInput;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="800", height="600")]
	public class TestTimeInput extends Sprite {
		public var timeInput: TimeInput;
		
		public function TestTimeInput() {
			timeInput = new TimeInput();
			timeInput.timeValue = 1234567;
			
			addChild(timeInput);
		}
	}
}
