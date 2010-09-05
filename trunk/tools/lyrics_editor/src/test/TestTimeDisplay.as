package test {
	import vn.karaokeplayer.lyricseditor.controls.TimeDisplay;

	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#666666", frameRate="31", width="800", height="600")]
	public class TestTimeDisplay extends Sprite {
		public var timeDisplay: TimeDisplay;
		
		public function TestTimeDisplay() {
			timeDisplay = new TimeDisplay();
			timeDisplay.timeValue = 1234567;
			timeDisplay.changed.add(timeChangedHandler);
			addChild(timeDisplay);
		}

		private function timeChangedHandler(timeValue: uint): void {
			trace("time changed " + timeValue);
		}
	}
}
