package test {
	import flash.utils.getTimer;
	import flash.xml.XMLDocument;
	import flash.display.Sprite;
	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#000000", frameRate="31", width="800", height="600")]
	public class TestHTMLEntity extends Sprite {
				

		public function TestHTMLEntity() {
			var s: String = "thanh&apos; asdasd &lt;asdas&gt; &apos; adsas adasdas &quot; asd asda sda";
			var result: String;
			var i:int;			
			var start: int = getTimer();
			for(i = 0; i < 10000; ++i) {
				result = XML(s).toString();
				//new XMLDocument(s).firstChild.nodeValue
				//trace("result: " + result);
			}
			trace("time for XML: " + (getTimer() - start));
			
			start = getTimer();
			for(i = 0; i < 10000; ++i) {
				result = new XMLDocument(s).firstChild.nodeValue;
				//trace("result: " + result);
			}
			trace("time for XML: " + (getTimer() - start));			
			
		}
	}
}
