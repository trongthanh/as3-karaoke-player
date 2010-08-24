package test {
	import vn.karaokeplayer.utils.StringUtil;
	import vn.karaokeplayer.lyricseditor.textarea.TextArea;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="800", height="600")]
	public class TestEditorTextArea extends Sprite {
		public var textArea: TextArea;
		
		private var _dummyHTML: XML = <p>
			<a class="synced" href="event:text_link1">[00:00:14.123]</a>We were <a class="synced" href="event:text_link2">[00:00:16.111]</a>both young<br/>
			<a href="event:text_link3">[00:00:20.555]</a>when I first <a href="event:text_link4">[00:00:23.111]</a>saw you<br/>
			<a href="event:text_link5">[00:00:26.111]</a>I closed my eye<br/>
			<a href="event:text_link6">[00:00:34.000]</a>and the flashback <a href="event:text_link7">[00:00:36.111]</a>starts<br/>
			</p>;
		
		public function TestEditorTextArea() {
			textArea = new TextArea();
			addChild(textArea);
			
			textArea.htmlText = StringUtil.removeNewLines(_dummyHTML.toString());
		}
	}
}
