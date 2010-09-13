package vn.karaokeplayer.lyricseditor.controls {
	import vn.karaokeplayer.IKarPlayer;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author Thanh Tran
	 */
	public class KaraokePreviewScreen extends Sprite {
		public var karPlayer: IKarPlayer;
		
		public function KaraokePreviewScreen(w: Number, h: Number) {
			//create gray layer
			graphics.beginFill(0x000000, 0.8);
			graphics.drawRect(0, 0, w, h)
			
			super.visible = false; // hidden by default
		}
		
		public function setKarPlayer(karPlayer: IKarPlayer): void {
			this.karPlayer = karPlayer;
			addChild(DisplayObject(karPlayer));
		}

		override public function set visible(value: Boolean): void {
			if(value != super.visible) {
//				if(value) {
//					GTweener.to(this, 0.5, {alpha: 1}, null, {AutoHideEnabled: true});
//				} else {
//					GTweener.to(this, 0.5, {alpha: 0}, null, {AutoHideEnabled: true});
//				}
			}
			super.visible = value;
		}
		
	}
}
