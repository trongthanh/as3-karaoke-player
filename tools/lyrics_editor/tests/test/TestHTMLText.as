package test {
	import flash.text.TextFieldType;
	import vn.karaokeplayer.utils.StringUtil;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#FFFFFF", frameRate="31", width="800", height="600")]
	public class TestHTMLText extends Sprite {
		public var textField: TextField;
		
		public function TestHTMLText() {
			XML.ignoreWhitespace = true;
			
			textField = new TextField();
			textField.width = 600;
			textField.height = 400;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.type = TextFieldType.INPUT;
			textField.y = 100;
			textField.border = true;
			textField.defaultTextFormat = new TextFormat("_sans", 12);
			
			addChild(textField);
			var str: String = StringUtil.removeNewLines(htmlStr.toString());
			textField.htmlText = str;
			
		}

		private var htmlStr: XML = <p>
			<a href="#something">[00:00:14.123]</a>We were <a href="#something">[00:00:16.111]</a>both young<br/>
			<a href="#something">[00:00:20.555]</a>when I first <a href="#something">[00:00:23.111]</a>saw you<br/>
			<a href="#something">[00:00:26.111]</a>I closed my eye<br/>
			<a href="#something">[00:00:34.000]</a>and the flashback <a href="#something">[00:00:36.111]</a>starts<br/>
			</p>;
	}
}
