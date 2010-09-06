package vn.karaokeplayer.data {

	/**
	 * This interface is to imporve independency of SongLyrics & SongInfo class 
	 * @author Thanh Tran
	 */
	public interface ISongLyrics {
		function addLine(line: LineInfo): void;	
	}
}
