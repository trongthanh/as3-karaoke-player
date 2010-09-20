package vn.karaokeplayer.lyricseditor.controls {
	import vn.karaokeplayer.lyricseditor.utils.DisplayObjectUtil;
	import fl.controls.Button;

	import vn.karaokeplayer.lyricseditor.utils.FontLib;

	import org.osflash.signals.Signal;

	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.text.TextField;

	/**
	 * @author Thanh Tran
	 */
	[Embed(source="/../assets/swc/controls_ui.swf", symbol="vn.karaokeplayer.lyricseditor.ui.TopBarUI")]
	public class TopControlBar extends Sprite {
		//stage
		public var newButton: SimpleButton;
		public var openLyricButton: SimpleButton;
		public var openMp3Button: SimpleButton;
		public var saveButton: SimpleButton;
		public var previewXmlButton: Button;
		public var testKaraokeButton: Button;
		public var lyricText: TextField;
		public var mp3Text: TextField;
		
		public var insertButton: SimpleButton;
		public var validateButton: SimpleButton;
		
		//signals
		/**
		 * Arguments: fileURL (String)
		 */
		public var audioFileSelected: Signal;
		/**
		 * Arguments: fileURL (String)
		 */
		public var lyricFileSelected: Signal;
		/**
		 * Arguments: 
		 */
		public var insertTimeMarkSelected: Signal;
		/**
		 * Arguments: 
		 */
		public var validateTimeMarkSelected: Signal;
		/**
		 * Arguments: selected (Boolean)
		 */
		public var testKaraokeToggled: Signal;
		
		/**
		 * Arguments: 
		 */
		public var saveLyricsSelected: Signal;
		
		
				
		
		//props
		private var _audioFile: File;
		private var _lyricFile: File;
		
		public function TopControlBar() {
			init();
		}

		private function init(): void {
			previewXmlButton = new Button();
			previewXmlButton.label = "Preview XML";
			previewXmlButton.width = 105;
			previewXmlButton.height = 28;
			previewXmlButton.x = 569;
			previewXmlButton.y = 11;
			
			testKaraokeButton = new Button();
			testKaraokeButton.label = "Test Karaoke";
			testKaraokeButton.width = 93;
			testKaraokeButton.height = 28;
			testKaraokeButton.x = 697;
			testKaraokeButton.y = 11;
			testKaraokeButton.toggle = true;
				
//			addChild(previewXmlButton); //need not for now
			addChild(testKaraokeButton);
			addChild(insertButton);
			addChild(validateButton);
			
			newButton.addEventListener(MouseEvent.CLICK, newButtonClickHandler);
			openLyricButton.addEventListener(MouseEvent.CLICK, openLyricButtonClickHandler);
			openMp3Button.addEventListener(MouseEvent.CLICK, openMp3ButtonClickHandler);
			saveButton.addEventListener(MouseEvent.CLICK, saveButtonClickHandler);
			previewXmlButton.addEventListener(MouseEvent.CLICK, previewXmlButtonClickHandler);
			testKaraokeButton.addEventListener(Event.CHANGE, testKaraokeChangeHandler)
			insertButton.addEventListener(MouseEvent.CLICK, insertButtonClickHandler);
			validateButton.addEventListener(MouseEvent.CLICK, validateButtonClickHandler);
			
			FontLib.initTextField(lyricText);
			FontLib.initTextField(mp3Text);
			lyricText.text = "Lyrics: N/A";
			mp3Text.text = "MP3: N/A";
			
			audioFileSelected = new Signal(String);
			lyricFileSelected = new Signal(String);
			insertTimeMarkSelected = new Signal();
			validateTimeMarkSelected = new Signal();
			testKaraokeToggled = new Signal(Boolean);
			saveLyricsSelected = new Signal(String);
			
			ToolTip.attach(newButton, "Create new lyrics file");
			ToolTip.attach(openLyricButton, "Open lyrics file");
			ToolTip.attach(openMp3Button, "Open MP3 file");
			ToolTip.attach(saveButton, "Save lyrics file as ttl/xml format");
			ToolTip.attach(insertButton, "Insert time mark");
			ToolTip.attach(validateButton, "Validate time marks");
		}


		private function newButtonClickHandler(event: MouseEvent): void {
			
		}

		private function openLyricButtonClickHandler(event: MouseEvent): void {
			_lyricFile = new File();
			_lyricFile.addEventListener(Event.SELECT, lyricFileSelectHandler, false,0,true);
			_lyricFile.browse([new FileFilter("Lyric Text File", "*.xml;*.txt;*.lrc;*.ttl")]);
			
		}

		private function lyricFileSelectHandler(event: Event): void {
			lyricText.text = "Lyrics: " + _lyricFile.name;
			lyricFileSelected.dispatch(_lyricFile.url);
		}

		private function openMp3ButtonClickHandler(event: MouseEvent): void {
			_audioFile = new File();
			_audioFile.addEventListener(Event.SELECT, audioFileSelectHandler, false,0,true);
			_audioFile.browse([new FileFilter("MP3", "*.mp3")]);			
		}

		private function audioFileSelectHandler(event: Event): void {
			//trace("audio file: " + _audioFile.url);
			audioFileSelected.dispatch(_audioFile.url);
			mp3Text.text = "MP3: " + _audioFile.name;
		}

		private function saveButtonClickHandler(event: MouseEvent): void {
			_lyricFile = new File();
			_lyricFile.addEventListener(Event.SELECT, lyricFileSaveSelectHandler, false,0,true);
			_lyricFile.browseForSave("Save Lyrics File");
			
			
		}
		
		private function lyricFileSaveSelectHandler(e:Event):void {
			saveLyricsSelected.dispatch(_lyricFile.url);
		}

		private function previewXmlButtonClickHandler(event: MouseEvent): void {
		}

		private function testKaraokeChangeHandler(event: Event): void {
			var selected: Boolean = testKaraokeButton.selected;
			if(selected) {
				testKaraokeButton.label = "Edit Lyrics";
				DisplayObjectUtil.disableControl(insertButton);
				DisplayObjectUtil.disableControl(validateButton);
			} else {
				testKaraokeButton.label = "Test Karaoke";
				DisplayObjectUtil.enableControl(insertButton);
				DisplayObjectUtil.enableControl(validateButton);
			}
			testKaraokeToggled.dispatch(selected);
		}

		private function insertButtonClickHandler(event: MouseEvent): void {
			insertTimeMarkSelected.dispatch();
		}

		private function validateButtonClickHandler(event: MouseEvent): void {
			validateTimeMarkSelected.dispatch();
		}
	}
}
