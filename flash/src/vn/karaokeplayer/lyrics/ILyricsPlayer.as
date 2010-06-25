package vn.karaokeplayer.lyrics {
	import vn.karaokeplayer.data.SongLyrics;

	/**
	 * @author Thanh Tran
	 */
	public interface ILyricsPlayer {
		function init(lyrics: SongLyrics): void;
		
		/**
		 * TODO: enble seeking, user can seek to any position
		 */
		function set position(position: Number): void;
		
		/**
		 * Test release memory
		 */
		function cleanUp(): void;
	}
}
