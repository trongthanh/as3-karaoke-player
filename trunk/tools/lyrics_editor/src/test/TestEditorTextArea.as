package test {
	import fl.controls.Button;

	import vn.karaokeplayer.lyricseditor.textarea.TextArea;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#CCDDEE", frameRate="31", width="800", height="600")]
	public class TestEditorTextArea extends Sprite {
		public var textArea: TextArea;
		public var insertButton: Button;
		
		private var _dummyHTML: String = 
			'<FONT COLOR="#FF0000"><A HREF="event:14123">{00:14.123}</A></FONT>We were <FONT COLOR="#FF0000"><A HREF="event:16111">{00:16.111}</A></FONT>both young<br/>' +
			'<FONT COLOR="#FF0000"><A HREF="event:20255">{00:20.555}</A></FONT>when I first <FONT COLOR="#FF0000"><A HREF="event:23111">{00:23.111}</A></FONT>saw you<br/>' +
			'<FONT COLOR="#FF0000"><A HREF="event:26111">{00:26.111}</A></FONT>I closed my eye<br/>' +
			'<FONT COLOR="#FF0000"><A HREF="event:34000">{00:34.000}</A></FONT>and the flashback <FONT COLOR="#FF0000"><A HREF="event:36111">{00:36.111}</A></FONT>starts<br/>';
		private var _dummyLyrics: String = 
			'We were both young<br/>' +
			'when I first saw you<br/>';
//			'I closed my eye<br/>' +
//			'and the flashback starts';
		 
		
		public function TestEditorTextArea() {
			textArea = new TextArea();
			textArea.y = 40;
			
			addChild(textArea);
			
			
//			textArea.htmlText = _dummyHTML;
			textArea.htmlText = _dummyLyrics;
			
			insertButton = new Button();
			insertButton.label = "Insert Time";
			insertButton.addEventListener(MouseEvent.CLICK, insertButtonClickHandler);
			addChild(insertButton);
		}

		private function insertButtonClickHandler(event: MouseEvent): void {
			textArea.insertTimeMark();
		}
	}
}
