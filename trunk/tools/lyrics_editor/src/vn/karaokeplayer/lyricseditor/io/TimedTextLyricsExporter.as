package vn.karaokeplayer.lyricseditor.io {
	import vn.karaokeplayer.data.KarPlayerError;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.karplayer_internal;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;
	import vn.karaokeplayer.utils.StringUtil;
	import vn.karaokeplayer.utils.TimeUtil;
	
	use namespace karplayer_internal;
	/**
	 * this class will help export from KarPlayer internal data to timed text xml string
	 * @author Thanh Tran
	 */
	public class TimedTextLyricsExporter implements IExporter {
		private var _curStyle: String = "b";
		public static const STYLE_REG: RegExp = /([fmb]):([\w\W]+)/i;
		
		public function exportTo(lyricsFileInfo: LyricsFileInfo): Object {
			if (!lyricsFileInfo || lyricsFileInfo.plainstr == null || !lyricsFileInfo.songInfo) {
				throw new KarPlayerError(KarPlayerError.COMMON_ERROR, "Internal error. Cannot export lyrics");
				return null;
			}
			
			var head: String = exportHeadPart(lyricsFileInfo.songInfo);
			var body: String = exportBodyPart(lyricsFileInfo.plainstr);
			
			var s: String = '<tt xmlns="http://www.w3.org/ns/ttml" xmlns:tts="http://www.w3.org/ns/ttml#styling" xmlns:ttm="http://www.w3.org/ns/ttml#metadata" xmlns:kar="http://code.google.com/p/as3-karaoke-player">';
			s += head;
			s += body;
			s += '</tt>';
			
			var xml: XML;
			try {
				xml = XML(s);
			} catch (err:Error){
				throw new KarPlayerError(KarPlayerError.XML_ERROR, "Cannot export XML:\n" + err.getStackTrace());
			}
			
/*
 * 
 * <tt xml:lang="vi" 
	xmlns="http://www.w3.org/ns/ttml"
    xmlns:tts="http://www.w3.org/ns/ttml#styling"
    xmlns:ttm="http://www.w3.org/ns/ttml#metadata"
    xmlns:kar="http://code.google.com/p/as3-karaoke-player"> 
	<head>
		<metadata>
			<!-- make use of metadata supported by TimedText -->
			<ttm:title><![CDATA[Hạnh Phúc Bất Tận]]></ttm:title>
			<ttm:desc><![CDATA[Composed by: Nguyễn Đức Thuận<br/>Singers: Hồ Ngọc Hà ft. V.Music Band]]></ttm:desc>
			<ttm:copyright>Copyright (C) 2010 Thanh Tran - trongthanh@gmail.com</ttm:copyright>
			
			<!-- below are extra metadata proposed by Karplayer -->
			<kar:version>0.5</kar:version> <!-- format version of this file -->
			<kar:id>0001</kar:id> <!-- unique id for back-end identification or recording purposes -->
			<kar:composer>Nguyễn Đức Thuận</kar:composer> <!-- for info only -->
			<kar:styleof>Hồ Ngọc Hà ft. V.Music Band</kar:styleof> <!-- for info only; meaning the beat audio is in the style of singer/band/  -->
			<kar:genre>pop</kar:genre> <!-- for info only -->
			<kar:mood>love</kar:mood> <!-- mood of the song, for switching to appropriate background photo slideshow or video -->
			<kar:audio>mp3/hanh_phuc_bat_tan.mp3</kar:audio> <!-- path to the audio file -->
			
			<!-- to add your own metadata, create new element <kar:extra>  -->
			<kar:extra id="extraItem1">extra item 1</kar:extra>
			<kar:extra id="extraItem2">extra item 2</kar:extra>
		</metadata>
	</head>
	<body>
		<div style="f">
			<p begin="00:00:21.260">* * *</p> <!-- this first version will only support sequential begin -->
			<p begin="00:00:23.580">Thắp nến</p>
			<p begin="00:00:24.590">đêm nay</p>
		</div>
 */
			//trace("export: " + xml);
			return xml;
		}
		
		public function exportHeadPart(songInfo: SongInfo): String {
			var s: String = "<head><metadata>";
			//default properties
			s += '<ttm:title><![CDATA[' + songInfo.title + ']]></ttm:title>';
			s += '<ttm:desc><![CDATA[' + songInfo.description + ']]></ttm:desc>';
			s += '<ttm:copyright><![CDATA[' + songInfo.copyright + ']]></ttm:copyright>';
			s += '<kar:version>0.5</kar:version>';
			s += '<kar:id><![CDATA[' + songInfo.id + ']]></kar:id>';
			s += '<kar:composer><![CDATA[' + songInfo.composer + ']]></kar:composer>';
			s += '<kar:styleof><![CDATA[' + songInfo.styleof + ']]></kar:styleof>';
			s += '<kar:genre><![CDATA[' + songInfo.genre + ']]></kar:genre>';
			s += '<kar:mood><![CDATA[' + songInfo.mood + ']]></kar:mood>';
			s += '<kar:audio><![CDATA[' + songInfo.beatURL + ']]></kar:audio>';
			//trace('songInfo.genre: ' + (songInfo.genre));
			//trace('songInfo.mood: ' + (songInfo.mood));
			//extra props
			var extra: Object = songInfo.extra;
			if(extra) {
				for (var i : String in extra) {
					s += '<kar:extra id="' + i +'"><![CDATA[' + extra[i] + ']]></kar:extra>';
				}
			}
			//close the tags
			s += "</metadata></head>";
			
			return s;
		}
		
		public function exportBodyPart(lrc: String): String {
			var s : String = "<body>\n";
			var lines: Array = lrc.split(/\n|\r/);
			var len:int = lines.length;
			var l: String;
			//trace('len: ' + len + " first: " + lines[0]);
			
			for (var i : int = 0; i < len; i++) {
				l = lines[i];
				if (!l) continue;
				s += processLine(l);
			}
			s += "</body>";
			//trace('s: ' + (s));
			
			return s;
		}
		
		/**
		 * Processes a lrc lines and return proper timed text line
		 */
		public function processLine(line: String): String {
			var groups: Array = line.split("{");
			var len: int = groups.length;
			var block: Array;
			var s: String = '';
			var tm: String;
			var txt: String;
			var dur: uint = 0;
			for (var i:int = 1; i < len; i++) {
				block = groups[i].split("}");
				tm = StringUtil.trim(block[0]);
				txt = StringUtil.trim(block[1]);
				
				if (i == 1) {
					var styleTest: Object = STYLE_REG.exec(txt);
					if (styleTest) {
						_curStyle = String(styleTest[1]).toLowerCase();
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
			s = '<div style="' + _curStyle + '">\n' + s + '</div>\n';
			
			return s;
		}
		
	}
}
