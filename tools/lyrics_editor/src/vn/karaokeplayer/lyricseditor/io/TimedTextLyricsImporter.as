package vn.karaokeplayer.lyricseditor.io {
	import vn.karaokeplayer.lyricseditor.utils.HTMLHelper;
	import vn.karaokeplayer.data.BlockInfo;
	import vn.karaokeplayer.data.LineInfo;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;
	import vn.karaokeplayer.parsers.TimedTextParser;

	/**
	 * @author Thanh Tran
	 */
	public class TimedTextLyricsImporter implements IImporter {
		
		public function importFrom(src: Object): LyricsFileInfo {
			var xml: XML;
			try{
				xml = XML(src);
			}catch(error:Error){
				trace("cannot parse lyrics XML");				
			}
			if(!xml) return null;
			
			var songInfo: SongInfo = new TimedTextParser().parseXML(xml);
			
			var lyricsFile: LyricsFileInfo = new LyricsFileInfo();
			lyricsFile.songInfo = songInfo;
			
			//parse SongLyrics to htmlstr
			var htmlstr: String = "";
			var lines: Array = songInfo.lyrics.lyricLines;
			var line: LineInfo;
			var blocks: Array;
			var block: BlockInfo;
			var currStyle: String = "";
			var styleMark: Boolean = false;
			for (var i : int = 0; i < lines.length; i++) {
				line = lines[i];
				if (currStyle != line.styleName) {
					styleMark = true;
					currStyle = line.styleName;
				}
				blocks = line.lyricBlocks;
				
				for (var j : int = 0;j < blocks.length;j++) {
					block = blocks[j];
					htmlstr += HTMLHelper.generateTimeMarkLink(block.begin) + '<FONT FACE="DroidRegular" SIZE="14" COLOR="#000000" LETTERSPACING="0" KERNING="0">';
					if(styleMark) {
						htmlstr += currStyle.toUpperCase() + ": ";
						styleMark = false;	
					}
					htmlstr += block.text + "</FONT> ";
					//add end time at end of line since line can appear asynchronously
					if(j == blocks.length - 1) {
						var nextLine: LineInfo = lines[i+1];
						if(!nextLine || block.end != nextLine.lyricBlocks[0].begin) {
							//only add end time mark if this end of line is different from next line's begin
							//or it is the last line
							htmlstr += HTMLHelper.generateTimeMarkLink(block.end);
						}
						
					}
				}
				if(i < lines.length - 1) htmlstr += "<BR>";
			}
			
			lyricsFile.htmlstr = htmlstr;

			return lyricsFile;
		}
	}
}
