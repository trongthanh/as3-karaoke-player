package test {
	import vn.karaokeplayer.lyricseditor.controls.PlayerControlBar;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#001133", frameRate="31", width="800", height="600")]
	public class TestPlayerBar extends Sprite {
		public var player: PlayerControlBar;
		
		//When I Look At You - Miley Cirus.mp3
		public function TestPlayerBar() {
			player = new PlayerControlBar();
			player.open("When I Look At You - Miley Cirus.mp3");
			
			addChild(player);
		}
	}
}
