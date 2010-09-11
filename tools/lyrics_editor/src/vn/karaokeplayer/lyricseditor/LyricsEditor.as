package vn.karaokeplayer.lyricseditor {
	import flash.desktop.NativeApplication;
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;

	import vn.karaokeplayer.lyricseditor.controls.PlayerControlBar;
	import vn.karaokeplayer.lyricseditor.controls.SongSummaryBar;
	import vn.karaokeplayer.lyricseditor.controls.TopControlBar;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;
	import vn.karaokeplayer.lyricseditor.io.TimedTextLyricsImporter;
	import vn.karaokeplayer.lyricseditor.textarea.TextArea;
	import vn.karaokeplayer.lyricseditor.utils.FileSystemUtil;
	import vn.karaokeplayer.utils.KarPlayerVersion;

	import flash.display.Sprite;
	import flash.filesystem.File;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#EEEEEE", frameRate="31", width="800", height="600")]
	public class LyricsEditor extends Sprite {
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
			songSummary.versionText.text = "LyricsEditor " + getAppVersion() + " - KarPlayer " + KarPlayerVersion.VERSION;
			 
			
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
		
		private function getAppVersion():String {
			var appXml:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXml.namespace();
			var appVersion:String = appXml.ns::version[0];
			return appVersion;
		}

		private function timeMarkInsertHandler(): void {
			textArea.insertTimeMark(playerControl.currentTimer.timeValue);
		}

		private function lyricFileSelectHandler(fileURL: String): void {
			trace('lyric fileURL: ' + (fileURL));
			var rawStr: String = FileSystemUtil.readTextFile(fileURL);
			var lyricsFile: LyricsFileInfo;
			//check for extension:
			if(fileURL.indexOf(".xml") || fileURL.indexOf(".ttl")) {
				lyricsFile = new TimedTextLyricsImporter().importFrom(rawStr);
			}
			
			songSummary.setData(lyricsFile.songInfo);
			textArea.htmlText = lyricsFile.htmlstr;
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
