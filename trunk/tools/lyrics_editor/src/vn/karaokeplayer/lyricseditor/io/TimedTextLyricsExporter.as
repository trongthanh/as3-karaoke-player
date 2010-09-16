package vn.karaokeplayer.lyricseditor.io {
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.karplayer_internal;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;
	
	use namespace karplayer_internal;
	/**
	 * this class will help export from KarPlayer internal data to timed text xml string
	 * @author Thanh Tran
	 */
	public class TimedTextLyricsExporter implements IExporter {
		
		public function exportTo(lyricsFileInfo: LyricsFileInfo): Object {
			var str: String = lyricsFileInfo.plainstr;
			if(!str) return null;
			
			
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
			
			return null;
		}
		
		public function exportHeadPart(songInfo: SongInfo): String {
			var s: String = "<head><metadata>";
			//default properties
			s += '<ttm:title><![CDATA[' + songInfo.title + ']]></ttm:title>';
			s += '<ttm:desc><![CDATA[' + songInfo.title + ']]></ttm:desc>';
			s += '<ttm:copyright><![CDATA[' + songInfo.title + ']]></ttm:copyright>';
			s += '<kar:version>0.5</kar:version>';
			s += '<kar:id><![CDATA[' + songInfo.id + ']]></kar:id>';
			s += '<kar:composer><![CDATA[' + songInfo.composer + ']]></kar:composer>';
			s += '<kar:styleof><![CDATA[' + songInfo.styleof + ']]></kar:styleof>';
			s += '<kar:genre><![CDATA[' + songInfo.genre + '</kar:genre>';
			s += '<kar:mood><![CDATA[' + songInfo.mood + '</kar:mood>';
			s += '<kar:audio><![CDATA[' + songInfo.beatURL + ']]></kar:audio>';
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
			var s: String = "<body>";
			var curStyle: String = "b";
			var lines: Array = lrc.split("\n");
			var len:int = lines.length;
			var l: String;
			
			for (var i : int = 0; i < len; i++) {
				l = lines[i];
				if(!l) continue;
				
				
				
				
			}
			
			return s;
		}
		
		/**
		 * Processes a lrc lines and return proper timed text line
		 */
		public function processLine(l: String): String {
			var s: String;
			
			return s;
		}
		
	}
}
