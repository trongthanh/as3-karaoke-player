package test {
	import flash.events.MouseEvent;

	import vn.karaokeplayer.data.SongInfo;
	import fl.controls.Button;
	import vn.karaokeplayer.lyricseditor.controls.SongSummaryBar;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#001133", frameRate="31", width="800", height="600")]
	public class TestSongSummary extends Sprite {
		public var songSummary: SongSummaryBar;
		
		public var getDataButton: Button;
		
		public function TestSongSummary() {
			songSummary = new SongSummaryBar();
			
			var info: SongInfo = new SongInfo();
			info.title = "Con Đường Tình Yêu";
			info.composer = "Đào Trọng Thịnh";
			info.styleof = "Lam Trường";
			info.copyright = "2010 (C) trongthanh@gmail.com";
			info.description = "Có một con đường mang tên là tình yêu. Khi tôi bước một mình đếm những nỗi cô đơn";
			
			songSummary.setData(info);
			
			addChild(songSummary);
			
			getDataButton = new Button();
			getDataButton.label = "Get Data";
			getDataButton.addEventListener(MouseEvent.CLICK, insertButtonClickHandler);
			getDataButton.x = 300;
			addChild(getDataButton);
		}

		private function insertButtonClickHandler(event : MouseEvent) : void {
			var info: SongInfo = songSummary.getData();
			trace(info.title + "\n" + info.composer + "\n" + info.styleof + "\n" + info.copyright + "\n" + info.description);
		}
	}
}
