package vn.karaokeplayer.lyricseditor.io {
	import vn.karaokeplayer.utils.StringUtil;
	import vn.karaokeplayer.data.SongLyrics;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;

	/**
	 * @author Thanh Tran
	 */
	public class PlainTextImporter implements IImporter {
		public function importFrom(src: Object): LyricsFileInfo {
			var s: String = String(src);
			s = StringUtil.trimNewLine(s);
			var f: LyricsFileInfo;
			f.songInfo = new SongInfo();
			f.songInfo.lyrics = new SongLyrics(); //empty song lyrics
			f.htmlstr = s;
			f.plainstr = s;
			return f;
		}
	}
}
