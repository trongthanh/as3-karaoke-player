package {
	import flash.events.MouseEvent;
	import fl.controls.Button;
	import thanhtran.karaokeplayer.data.KarPlayerOptions;
	import thanhtran.karaokeplayer.KarPlayer;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	[SWF(backgroundColor="#CCCCCC", frameRate="31", width="600", height="400")]
	public class Main extends Sprite {
		public var karPlayer:KarPlayer;
		public var playButton: Button; 
		
		public function Main() {
			var karOptions: KarPlayerOptions = new KarPlayerOptions();
			karOptions.width = 600;
			karOptions.height = 400;
			karPlayer = new KarPlayer(karOptions);
			
			addChild(karPlayer);
			
			karPlayer.ready.add(playerReadyHandler);
			//karPlayer.loadSong("xml/song1.xml");
			//karPlayer.loadSong("xml/song2.xml");
			karPlayer.loadSong("xml/song3.xml");
		}

		private function playerReadyHandler(): void {
			playButton = new Button();
			playButton.label = "Play";
			playButton.addEventListener(MouseEvent.CLICK, playButtonHandler);
			addChild(playButton);
		}

		private function playButtonHandler(event: MouseEvent): void {
			karPlayer.play();	
			playButton.visible = false;		
		}
	}
}
