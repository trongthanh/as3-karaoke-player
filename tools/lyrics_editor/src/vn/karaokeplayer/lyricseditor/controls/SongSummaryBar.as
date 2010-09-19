package vn.karaokeplayer.lyricseditor.controls {
	import fl.controls.UIScrollBar;
	import vn.karaokeplayer.data.SongInfo;
	import vn.karaokeplayer.lyricseditor.utils.FontLib;

	import flash.display.Sprite;
	import flash.text.TextField;

	/**
	 * @author Thanh Tran
	 */
	[Embed(source="/../assets/swc/controls_ui.swf", symbol="vn.karaokeplayer.lyricseditor.ui.SongSummaryUI")]
	public class SongSummaryBar extends Sprite {
		//stage
		public var titleText: TextField;
		public var composerText: TextField;
		public var artistText: TextField;
		public var copyText: TextField;
		public var descText: TextField;

		public var descScroll: UIScrollBar;
		
		public var errorText: TextField;		
		public var versionText: TextField; //this text field uses _sans
		
		//props
		private var _songInfo: SongInfo;
		
		
		public function SongSummaryBar() {
			init();
		}

		private function init() : void {
			FontLib.initTextField(titleText);
			FontLib.initTextField(composerText);
			FontLib.initTextField(artistText);
			FontLib.initTextField(copyText);
			FontLib.initTextField(descText);
			FontLib.initTextField(errorText);
			
			titleText.text = "";
			composerText.text = "";
			artistText.text = "";
			copyText.text = "";
			descText.text = "";
			
			descScroll = new UIScrollBar();
			descScroll.x = 180;
			descScroll.y = 235;
			descScroll.height = 109;
			descScroll.scrollTarget = descText;
			
			addChild(descScroll);
		}

		public function setData(songInfo: SongInfo): void {
			_songInfo = songInfo;
			
			titleText.text = (_songInfo.title)? _songInfo.title : "" ;
			composerText.text = (_songInfo.composer)?_songInfo.composer : "";
			artistText.text = (_songInfo.composer)? _songInfo.styleof: "";
			copyText.text = (_songInfo.copyright)?_songInfo.copyright: "";
			descText.text = (_songInfo.description)?_songInfo.description:"";
			
			descScroll.update();
		}

		public function getData(): SongInfo {
			if(!_songInfo) _songInfo = new SongInfo();
			_songInfo.title = titleText.text;
			_songInfo.composer = composerText.text;
			_songInfo.styleof = artistText.text;
			_songInfo.copyright = copyText.text;
			_songInfo.description = descText.text;
			//TODO: implement later:
			//_songInfo.genre = "";
			//_songInfo.mood = "";
			//_songInfo.id = "";
			
			return _songInfo;	
		}
		
		public function setErrorMessage(txt: String): void {
			errorText.text = txt;
		}
	}
}
