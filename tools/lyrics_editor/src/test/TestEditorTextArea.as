package test {
	import vn.karaokeplayer.lyricseditor.io.TimedTextLyricsImporter;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.net.URLLoader;
	import vn.karaokeplayer.lyricseditor.utils.FontLib;
	import fl.controls.Button;

	import vn.karaokeplayer.lyricseditor.textarea.TextArea;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#EEEEEE", frameRate="31", width="800", height="600")]
	public class TestEditorTextArea extends Sprite {
		public var textArea: TextArea;
		public var insertButton: Button;
		public var fontlib: FontLib;
		
		private var _dummyHTML: String = 
			'<FONT FACE="DigitRegular" COLOR="#FF3300" SIZE="16"><A HREF="event:14123">00:14.123</A></FONT>We were <FONT FACE="DigitRegular" COLOR="#FF3300" SIZE="16"><A HREF="event:16111">00:16.111</A></FONT>both young<br/>' +
			'<FONT FACE="DigitRegular" COLOR="#FF3300" SIZE="16"><A HREF="event:20255">00:20.555</A></FONT>when I first <FONT FACE="DigitRegular" COLOR="#FF3300" SIZE="16"><A HREF="event:23111">00:23.111</A></FONT>saw you<br/>' +
			'<FONT FACE="DigitRegular" COLOR="#FF3300" SIZE="16"><A HREF="event:26111">00:26.111</A></FONT>I closed my eye<br/>' +
			'<FONT FACE="DigitRegular" COLOR="#FF3300" SIZE="16"><A HREF="event:34000">00:34.000</A></FONT>and the flashback <FONT FACE="DigitRegular" COLOR="#FF3300" SIZE="16"><A HREF="event:36111">00:36.111</A></FONT>starts<br/>';
		private var _dummyLyrics: String = 
			'We were both young<br/>' +
			'when I first saw you<br/>';
//			'I closed my eye<br/>' +
//			'and the flashback starts';
		 
		
		public function TestEditorTextArea() {
			textArea = new TextArea();
			textArea.y = 20;
			textArea.width = stage.stageWidth;
			textArea.height = stage.stageHeight - 20;
			
			addChild(textArea);
			
			
//			textArea.htmlText = _dummyHTML;
//			textArea.htmlText = _dummyLyrics;
			
			insertButton = new Button();
			insertButton.label = "Insert Time";
			insertButton.addEventListener(MouseEvent.CLICK, insertButtonClickHandler);
			addChild(insertButton);
			
			var xmlLoader: URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, loadCompleteHandler);
			xmlLoader.load(new URLRequest("song1.xml"));
		}

		private function loadCompleteHandler(event: Event): void {
			var rawStr: String = String(URLLoader(event.target).data);
			var lyricsFile: LyricsFileInfo;
			//check for extension:
			lyricsFile = new TimedTextLyricsImporter().importFrom(rawStr);

			textArea.htmlText = lyricsFile.htmlstr;
		}

		private function insertButtonClickHandler(event: MouseEvent): void {
			textArea.insertTimeMark();
		}
	}
}
