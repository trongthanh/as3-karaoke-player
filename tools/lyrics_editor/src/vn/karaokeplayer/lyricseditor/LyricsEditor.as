package vn.karaokeplayer.lyricseditor {
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;

	import vn.karaokeplayer.IKarPlayer;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.lyricseditor.controls.KaraokePreviewScreen;
	import vn.karaokeplayer.lyricseditor.controls.PlayerControlBar;
	import vn.karaokeplayer.lyricseditor.controls.SongSummaryBar;
	import vn.karaokeplayer.lyricseditor.controls.ToolTip;
	import vn.karaokeplayer.lyricseditor.controls.TopControlBar;
	import vn.karaokeplayer.lyricseditor.data.LyricsFileInfo;
	import vn.karaokeplayer.lyricseditor.io.IExporter;
	import vn.karaokeplayer.lyricseditor.io.IImporter;
	import vn.karaokeplayer.lyricseditor.io.PlainTextImporter;
	import vn.karaokeplayer.lyricseditor.io.TimedTextLyricsExporter;
	import vn.karaokeplayer.lyricseditor.io.TimedTextLyricsImporter;
	import vn.karaokeplayer.lyricseditor.managers.ErrorMessageManager;
	import vn.karaokeplayer.lyricseditor.textarea.TextArea;
	import vn.karaokeplayer.lyricseditor.utils.DisplayObjectUtil;
	import vn.karaokeplayer.lyricseditor.utils.FileSystemUtil;
	import vn.karaokeplayer.lyricseditor.utils.FontLib;
	import vn.karaokeplayer.parsers.ILyricsParser;
	import vn.karaokeplayer.parsers.TimedTextParser;
	import vn.karaokeplayer.utils.KarPlayerVersion;

	import com.gskinner.motion.plugins.AutoHidePlugin;

	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.filesystem.File;

	/**
	 * Thanh Tran: Please bear with me. This program was made with poor architecture design and planning due to my lack of motivation recently.
	 * I intend to refactor it later.
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
		public var audioURL: String;
		private var appUpdater:ApplicationUpdaterUI	= new ApplicationUpdaterUI();
		
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
			songSummary.versionText.text = "LyricsEditor " + getAppVersion() + " - KarPlayer " + KarPlayerVersion.MAJOR + "." + KarPlayerVersion.MINOR;
			
			ErrorMessageManager.init(songSummary.errorText);
			
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
			topControl.insertTimeMarkSelected.add(timeMarkInsertHandler);
			topControl.validateTimeMarkSelected.add(timeMarkValidateHandler);
			topControl.testKaraokeToggled.add(testKaraokeHandler);
			topControl.saveLyricsSelected.add(lyricsSaveHandler);
			topControl.newLyricSelected.add(newLyricHandler);
			
			topControl.testKaraokeButton.enabled = false;
			
			playerControl.playerReady.add(playerReadyHandler);
			
			textArea.validateOK.add(validateOKChangeHandler);
			validateOKChangeHandler(false);
		}

		private function newLyricHandler() : void {
			topControl.lyricText.text = "Lyrics: N/A";
			textArea.text = " ";
		}

		private function validateOKChangeHandler(ok: Boolean): void {
			if(ok) {
				DisplayObjectUtil.enableControl(topControl.validateButton);
			} else {
				DisplayObjectUtil.disableControl(topControl.validateButton);
			}
		}

		private function timeMarkValidateHandler() : void {
			if(textArea.validate()) {
				ErrorMessageManager.showMessage("Time marks validation OK.", true);
			} else {
				ErrorMessageManager.showMessage("Validation error: There must be 1 time mark at line start and end of song; time values must not reverse.");
			}
		}

		private function playerReadyHandler(): void {
			topControl.testKaraokeButton.enabled = true;
		}

		private function lyricsSaveHandler(fileURL: String):void {
			lyricsFile.plainstr = textArea.text;
			lyricsFile.songInfo = songSummary.getData();
			var exporter: IExporter = new TimedTextLyricsExporter();
			var xml: XML = XML(exporter.exportTo(lyricsFile));
			FileSystemUtil.writeXML(xml, fileURL);
		}

		private function testKaraokeHandler(selected: Boolean): void {
			if (selected) {
				if(textArea.validate()) {
					updateLyrics();
				} else {
					selected = false;
					topControl.toggleTestKaraokeButton(selected, true);
					ErrorMessageManager.showMessage("Validation error: There must be 1 time mark at line start and end of song; time values must not reverse.");
					
				}
			}
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
			var importer: IImporter;
			if (fileURL.indexOf(".xml") > 0 || fileURL.indexOf(".ttl") > 0) {
				importer = new TimedTextLyricsImporter();
				lyricsFile = importer.importFrom(rawStr);
			} else {
				//assume plain text
				importer = new PlainTextImporter();
				lyricsFile = importer.importFrom(rawStr);
			}
			
			songSummary.setData(lyricsFile.songInfo);
			textArea.htmlText = lyricsFile.htmlstr;
		}

		private function audioFileSelectHandler(fileURL: String): void {
			trace('mp3 fileURL: ' + (fileURL));
			audioURL = fileURL;
			if(!lyricsFile) {
				lyricsFile = new LyricsFileInfo();
				lyricsFile.songInfo = songSummary.getData();
				lyricsFile.htmlstr = textArea.htmlText;
				lyricsFile.plainstr = textArea.text;
				//worst code ever!!
				var exporter: IExporter = new TimedTextLyricsExporter();
				var xml: XML = XML(exporter.exportTo(lyricsFile));
				var parser: ILyricsParser = new TimedTextParser();
				var songInfo: SongInfo = parser.parseXML(xml);
				lyricsFile.songInfo = songInfo;		
				/*try{
				}catch(error: KarPlayerError) {
					lyricsFile.songInfo = new SongInfo();
					lyricsFile.songInfo.lyrics = new SongLyrics();
				}*/
			}
			
			lyricsFile.songInfo.beatURL = fileURL;
			playerControl.open(lyricsFile.songInfo);
		}
		
		private function updateLyrics(): void {
			lyricsFile.plainstr = textArea.text;
			var exporter: IExporter = new TimedTextLyricsExporter();
			var xml: XML = XML(exporter.exportTo(lyricsFile));
			var parser: ILyricsParser = new TimedTextParser();
			var songInfo: SongInfo = parser.parseXML(xml);
			var karplayer: IKarPlayer = playerControl.karPlayer;
			karplayer.lyricPlayer.cleanUp();
			karplayer.lyricPlayer.init(songInfo.lyrics);
		}

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
