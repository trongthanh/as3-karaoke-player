package com.realeyes.osmfplayer.controls
{
	import flash.display.MovieClip;
	
//TODO - should this be dynamic or not?	
	/**
	 * Base class for skin elements used in instantiation and layout of
	 * the components through the config file.
	 * 
	 * @author	RealEyes Media
	 * @version	1.0
	 */
	public dynamic class SkinElementBase extends MovieClip implements ISkinElementBase
	{
		
		/////////////////////////////////////////////
		//  DECLARATIONS
		/////////////////////////////////////////////
		private var _hAdjust:Number;
		private var _vAdjust:Number;
		
		private var _scaleMode:String;
		
		private var _hAlign:String;
		
		private var _vAlign:String;
		
		private var _autoPosition:Boolean;
		
		/////////////////////////////////////////////
		//  CONSTRUCTOR
		/////////////////////////////////////////////
		
		public function SkinElementBase()
		{
			super();
		}
		
		
		
		/////////////////////////////////////////////
		//  GETTER/SETTERS
		/////////////////////////////////////////////
		
		
		
		/**
		 * How many pixels should the component be shifted horizontally?	(Number)
		 */
		public function get hAdjust():Number
		{
			return _hAdjust;
		}

		public function set hAdjust(value:Number):void
		{
			_hAdjust = value;
		}

		/**
		 * How many pixels should the component be shifted vertically?	(Number)
		 */
		public function get vAdjust():Number
		{
			return _vAdjust;
		}

		public function set vAdjust(value:Number):void
		{
			_vAdjust = value;
		}

		/**
		 * How should the element scale? (FIT, SELECT, or NONE)	(String)
		 */
		public function get scaleMode():String
		{
			return _scaleMode;
		}

		public function set scaleMode(value:String):void
		{
			_scaleMode = value;
		}

		/**
		 * How should the element align horizontally? (LEFT, CENTER, RIGHT, or NONE)	(String)
		 */
		public function get hAlign():String
		{
			return _hAlign;
		}

		public function set hAlign(value:String):void
		{
			_hAlign = value;
		}

		/**
		 * How should the element align vertically? (TOP, CENTER, BOTTOM, or NONE)	(String)
		 */
		public function get vAlign():String
		{
			return _vAlign;
		}

		public function set vAlign(value:String):void
		{
			_vAlign = value;
		}

		/**
		 * Should the element automatically be positioned in its container?	(Boolean)
		 */
		public function get autoPosition():Boolean
		{
			return _autoPosition;
		}
		
		public function set autoPosition(value:Boolean):void
		{
			_autoPosition = value;
		}


	}
}