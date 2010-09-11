package vn.karaokeplayer.lyricseditor.io {
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;

	/**
	 * @author Thanh Tran
	 */
	public interface IImporter {
		
		function importFrom(src: Object): LyricsFileInfo;
	}
}
