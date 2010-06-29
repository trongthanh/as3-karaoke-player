package com.realeyes.osmfplayer.controls
{
	import flash.events.IEventDispatcher;

	public interface ISkinElementBase extends IEventDispatcher
	{
		
		function get width():Number;
		function set width(value:Number):void;
		
		function get height():Number;
		function set height(value:Number):void;
		
		
		function get x():Number;
		function set x(value:Number):void;
		
		function get y():Number;
		function set y(value:Number):void;
		
		function get visible():Boolean;
		function set visible(value:Boolean):void;
		
		
		/**
		 * How many pixels should the component be shifted horizontally?	(Number)
		 */
		function get hAdjust():Number;
		function set hAdjust(value:Number):void;
		
		/**
		 * How many pixels should the component be shifted vertically?	(Number)
		 */
		function get vAdjust():Number;
		function set vAdjust(value:Number):void;
		
		/**
		 * How should the element scale? (FIT, SELECT, or NONE)	(String)
		 */
		function get scaleMode():String;
		function set scaleMode(value:String):void;
		
		/**
		 * How should the element align horizontally? (LEFT, CENTER, RIGHT, or NONE)	(String)
		 */
		function get hAlign():String;
		function set hAlign(value:String):void;
		
		/**
		 * How should the element align vertically? (TOP, CENTER, BOTTOM, or NONE)	(String)
		 */
		function get vAlign():String;
		function set vAlign(value:String):void;
		
		/**
		 * Should the element automatically be positioned in its container?	(Boolean)
		 */
		function get autoPosition():Boolean;
		function set autoPosition(value:Boolean):void;
	}
}