package vn.karaokeplayer.lyricseditor.io {
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;

	/**
	 * @author Thanh Tran
	 */
	public interface IExporter {
		
		function exportTo(lyricsFileInfo: LyricsFileInfo): Object;
	}
}
