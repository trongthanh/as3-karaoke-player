package vn.karaokeplayer.lyricseditor {
	import fl.controls.UIScrollBar;

	import vn.karaokeplayer.lyricseditor.controls.PlayerControlBar;
	import vn.karaokeplayer.lyricseditor.controls.SongSummaryBar;
	import vn.karaokeplayer.lyricseditor.controls.TopControlBar;
	import vn.karaokeplayer.lyricseditor.textarea.TextArea;

	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#CCCCCC", frameRate="31", width="800", height="600")]
	public class LyricsEditor extends Sprite {
		public var topControl: TopControlBar;
		public var songSummary: SongSummaryBar;
		public var playerControl: PlayerControlBar;
		public var textArea: TextArea;
		public var textAreaScroll: UIScrollBar;
		
		
		public function LyricsEditor() {
			init();
		}

		private function init(): void {
			topControl = new TopControlBar();

			songSummary = new SongSummaryBar();
			songSummary.y = 100;
			
			textArea = new TextArea();
			textArea.width = 585;
			textArea.height = 458;//to full line
			textArea.x = 200;
			textArea.y = 100;
			
			textAreaScroll = new UIScrollBar();
			textAreaScroll.x = 785;
			textAreaScroll.y = 100;
			textAreaScroll.height = 450;
			textAreaScroll.scrollTarget = textArea.textField;
			
			playerControl = new PlayerControlBar();
			playerControl.y = 550;
			
			addChild(playerControl);
			addChild(textArea);
			addChild(textAreaScroll);
			addChild(songSummary);
			addChild(topControl);			
		}
	}
}
