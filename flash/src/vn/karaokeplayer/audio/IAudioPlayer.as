package vn.karaokeplayer.audio {
	import org.osflash.signals.ISignal;
	import flash.media.Sound;

	/**
	 * @author Thanh Tran
	 */
	public interface IAudioPlayer {
		
		/**
		 * TODO: create test case to test this flow
		 */
		function init(sound: Sound): void;

		function open(soundURL: String): void;

		/**
		 *  play the beat
		 */
		function play(startTime: Number = 0): void;
		function pause(): void;
		function stop(): void;
		function seek(pos: Number): Boolean;
		
		function get position(): Number;
		function get length(): Number;
		function get playing(): Boolean;
		function get pausing(): Boolean;
		function get autoPlay(): Boolean;
		function set autoPlay(autoPlay: Boolean): void;
		
		function get audioCompleted(): ISignal;
		function get ready(): ISignal;
		function get loadProgress(): ISignal;
		function get loadCompleted(): ISignal;
	}
}
