package vn.karaokeplayer.lyricseditor {
	import air.update.events.UpdateEvent;

	import flash.filesystem.File;

	import air.update.ApplicationUpdaterUI;

	import vn.karaokeplayer.lyricseditor.controls.PlayerControlBar;
	import vn.karaokeplayer.lyricseditor.controls.SongSummaryBar;
	import vn.karaokeplayer.lyricseditor.controls.TopControlBar;
	import vn.karaokeplayer.lyricseditor.textarea.TextArea;
	import vn.karaokeplayer.lyricseditor.utils.FileSystemUtil;
	import vn.karaokeplayer.utils.StringUtil;
	import vn.karaokeplayer.utils.KarPlayerVersion;

	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#DDDDDD", frameRate="31", width="800", height="600")]
	public class LyricsEditor extends Sprite {
		public static const VERSION: String = "0.1";
		
		public var topControl: TopControlBar;
		public var songSummary: SongSummaryBar;
		public var playerControl: PlayerControlBar;
		public var textArea: TextArea;
		
		
		public function LyricsEditor() {
			init();
			checkForUpdates();
		}

		private function init(): void {
			topControl = new TopControlBar();

			songSummary = new SongSummaryBar();
			songSummary.y = 100;
			songSummary.versionText.text = "LyricsEditor " + VERSION + " - KarPlayer " + KarPlayerVersion.VERSION; 
			
			textArea = new TextArea();
			textArea.width = 600;
			textArea.height = 450;//to full line
			textArea.x = 200;
			textArea.y = 100;
			
			playerControl = new PlayerControlBar();
			playerControl.y = 550;
			
			addChild(playerControl);
			addChild(textArea);
			addChild(songSummary);
			addChild(topControl);
			
			topControl.audioFileSelected.add(audioFileSelectHandler);
			topControl.lyricFileSelected.add(lyricFileSelectHandler);
			topControl.timeMarkInserted.add(timeMarkInsertHandler);
		}

		private function timeMarkInsertHandler(): void {
			textArea.insertTimeMark(playerControl.currentTimer.timeValue);
		}

		private function lyricFileSelectHandler(fileURL: String): void {
			trace('lyric fileURL: ' + (fileURL));
			textArea.htmlText = StringUtil.trimNewLine(FileSystemUtil.readTextFile(fileURL));
		}

		private function audioFileSelectHandler(fileURL: String): void {
			trace('mp3 fileURL: ' + (fileURL));
			playerControl.open(fileURL);
		}
		
		
		private var appUpdater:ApplicationUpdaterUI	= new ApplicationUpdaterUI();
		
		private function checkForUpdates():void {
			appUpdater.configurationFile = new File("app:/updater_config.xml");
			appUpdater.addEventListener(UpdateEvent.INITIALIZED, updaterInitialised);
			appUpdater.initialize();
		}
		private function updaterInitialised(event: UpdateEvent):void {
			appUpdater.checkNow();
		}
	}
}
