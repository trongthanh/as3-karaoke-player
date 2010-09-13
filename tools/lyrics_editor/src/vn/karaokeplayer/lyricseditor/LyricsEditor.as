package vn.karaokeplayer.lyricseditor {
	import vn.karaokeplayer.lyricseditor.controls.KaraokePreviewScreen;
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;

	import vn.karaokeplayer.lyricseditor.controls.PlayerControlBar;
	import vn.karaokeplayer.lyricseditor.controls.SongSummaryBar;
	import vn.karaokeplayer.lyricseditor.controls.ToolTip;
	import vn.karaokeplayer.lyricseditor.controls.TopControlBar;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;
	import vn.karaokeplayer.lyricseditor.io.TimedTextLyricsImporter;
	import vn.karaokeplayer.lyricseditor.textarea.TextArea;
	import vn.karaokeplayer.lyricseditor.utils.FileSystemUtil;
	import vn.karaokeplayer.lyricseditor.utils.FontLib;
	import vn.karaokeplayer.utils.KarPlayerVersion;

	import com.gskinner.motion.plugins.AutoHidePlugin;

	import flash.desktop.NativeApplication;
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
		public var karaokePreviewScreen: KaraokePreviewScreen;
		
		//props
		public var lyricsFile: LyricsFileInfo;
		
		
		public function LyricsEditor() {
			init();
			checkForUpdates();
		}

		private function init(): void {
			//init tooltip
			ToolTip.init(stage, 
			{
				textAlign: 'center',
				textColor: 0xFFFFFF,
				opacity: 70, 
				defaultDelay: 200,
				bgColor: 0x000000,
				borderColor: 'none',
				cornerRadius: 5,
				shadow: true,
				top: 10,
				left: 10,
				right: 10,
				bottom: 10,
				fadeTime: 100,
				fontSize: 14,
				fontFace: FontLib.DEFAULT_FONT_NAME,
				fontEmbed: true
			});
			
			//init tween plugin
			AutoHidePlugin.install();
			AutoHidePlugin.enabled = false; //disabled by default
			
			
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
			
			
			karaokePreviewScreen = new KaraokePreviewScreen(600, 450);
			karaokePreviewScreen.x = 200;
			karaokePreviewScreen.y = 100;
			karaokePreviewScreen.setKarPlayer(playerControl.karPlayer);
			
			addChild(playerControl);
			addChild(textArea);
			addChild(songSummary);
			addChild(topControl);
			addChild(karaokePreviewScreen);
			
			topControl.audioFileSelected.add(audioFileSelectHandler);
			topControl.lyricFileSelected.add(lyricFileSelectHandler);
			topControl.timeMarkInserted.add(timeMarkInsertHandler);
			topControl.testKaraokeToggled.add(testKaraokeHandler);
		}

		private function testKaraokeHandler(selected: Boolean): void {
			karaokePreviewScreen.visible = selected;
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
			//check for extension:
			if(fileURL.indexOf(".xml") || fileURL.indexOf(".ttl")) {
				lyricsFile = new TimedTextLyricsImporter().importFrom(rawStr);
			}
			
			songSummary.setData(lyricsFile.songInfo);
			textArea.htmlText = lyricsFile.htmlstr;
		}

		private function audioFileSelectHandler(fileURL: String): void {
			trace('mp3 fileURL: ' + (fileURL));
			lyricsFile.songInfo.beatURL = fileURL;
			playerControl.open(lyricsFile.songInfo);
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
