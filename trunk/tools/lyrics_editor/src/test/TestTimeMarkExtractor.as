package test {
	import flash.display.Sprite;
	import vn.karaokeplayer.utils.StringUtil;
	import vn.karaokeplayer.utils.TimeUtil;
	
	/**
	 * ...
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#000000", frameRate="31", width="800", height="600")]
	public class TestTimeMarkExtractor extends Sprite {
		public var mockupLrc: String = "{00:36.360}F: hạnh phúc {00:37.110}lứa đôi {00:38.090}tràn {00:38.490}dâng {00:41.490}";
		//public var blockReg: RegExp = /{(\d*:)?\d*:\d*.\d}/;
		public var styleReg: RegExp = /([fmb]):([\w\W]+)/i;
		public function TestTimeMarkExtractor() {
			var groups: Array = mockupLrc.split("{");
			var len: int = groups.length;
			var block: Array;
			var curStyle: String = "";
			var s: String = '';
			var tm: String;
			var txt: String;
			var dur: uint = 0;
			for (var i:int = 1; i < len; i++) {
				block = groups[i].split("}");
				tm = StringUtil.trim(block[0]);
				txt = StringUtil.trim(block[1]);
				
				if (i == 1) {
					var styleTest: Object = styleReg.exec(txt);
					if (styleTest) {
						curStyle = String(styleTest[1]).toLowerCase();
						txt = String(styleTest[2]);
					}
				}
				
				if (i == len - 2) {
					var lastBlock: Array = groups[i + 1].split("}");
					if (!StringUtil.trim(lastBlock[1])) {
						//has end mark, set this as duration
						dur = TimeUtil.clockStringToMs(lastBlock[0]) - TimeUtil.clockStringToMs(tm);
						if (dur)
							s += '<p begin="' + tm + '" dur="' + dur + '">' + txt + '</p>\n';
						break;
					}
				}
				
				s += '<p begin="' + tm + '">' + txt + '</p>\n';
				
			}
			s = '<div style="' + curStyle + '">\n' + s + '</div>';
			
			trace(s);
		}
		
	}

}