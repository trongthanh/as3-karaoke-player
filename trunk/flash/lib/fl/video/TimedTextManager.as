// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.video {

	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;

	use namespace flvplayback_internal;

	/**
	 * <p>Handles downloading and parsing Timed Text (TT) xml format
	 * for fl.video.FLVPlayback. See fl.video.FLVPlaybackCaptioning
	 * for more info on the subset of Timed Text supported.</p>
	 * 
	 * <p>When the timed text is parsed it is turned into ActionScript
	 * cue points which are added to the FLVPlayback instance's list.
	 * The cue points use the naming convention of beginning with the
	 * prefix "fl.video.caption.", so users should not create any cue points
	 * with names like this unless they want them used for captioning,
	 * and users who are doing general cue point handling should
	 * ignore cue points with names like this.</p>
	 * 
	 * <p>The ActionScript cue points created have the following
	 * attributes:</p>
	 * 
	 * <ul>
	 * 
	 *   <li>name: starts with prefix "fl.video.caption." followed by
	 *   a version number ("2.0" for this release) and then has some
	 *   arbitrary string after that.  In practice the string is
	 *   simply a series of positive integers incremented each time to
	 *   keep each name unique.  It is not necessary that each name be
	 *   unique.</li>
	 * 
	 *   <li>time: the time when the caption should display.</li>
	 * 
	 *   <li>parameters:</li>
	 *
	 *   <ul>
	 *
	 *     <li>text:String - html formatted text for the caption.
	 *     This text is passed directly to the TextField.htmlText
	 *     property. </li>
	 * 
	 *     <li>endTime:Number - the time when the caption should
	 *     disappear.  if this is NaN, then the caption will display
	 *     until the flv completes, i.e. the FLVPlayback instance
	 *     dispatches the <code>VideoEvent.COMPLETE</code> event.</li>
	 * 
	 *     <li>url:String - this is the URL which the timed text xml
	 *     was loaded from.  This is used so that if multiple urls are
	 *     loaded, for example if the English captions are loaded
	 *     initially, but then the user switches to the German
	 *     captions, the already created captions for English will be
	 *     ignored.  If captions are discovered with url undefined,
	 *     they will always be displayed (this is to support creating
	 *     caption cue points via other means, see below).</li>
	 * 
	 *     <li>backgroundColor:uint - sets TextField.backgroundColor</li>
	 * 
	 *     <li>backgroundColorAlpha:Boolean - true if backgroundColor
	 *     has alpha of 0%, the only alpha we respect (other than
	 *     100%).  Sets TextField.background = !backgroundColor.</li>
	 * 
	 *     <li>wrapOption:Boolean - sets TextField.wordWrap</li>
	 * 
	 *   </ul>
	 * 
	 * </ul>
	 * 
	 * <p>If a user created his or her own cue points that stick to
	 * this standard, whether they be AS cue points or cue points
	 * embedded in the FLV, they would also work with the
	 * FLVPlaybackCaptioning component.</p>
	 * 
	 * @see fl.video.FLVPlaybackCaptioning
     * @private
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class TimedTextManager {

		include "ComponentVersion.as"

		flvplayback_internal var owner:FLVPlaybackCaptioning;

		private var flvPlayback:FLVPlayback;
		private var videoPlayerIndex:uint;
		private var limitFormatting:Boolean;

		// tt support
		public var xml:XML;
		public var xmlLoader:URLLoader;

		private var _url:String;

		// counter for cue point names
		flvplayback_internal var nameCounter:uint;

		// last cue point generated in case it needs be fixed
		// later due to no dur or end attribute
		flvplayback_internal var lastCuePoint:Object;

		// array of objects used as a stack to push on/pop off new style state
		flvplayback_internal var styleStack:Array;
		flvplayback_internal var definedStyles:Object;
		flvplayback_internal var styleCounter:uint;

		// how we handle whitespace
		flvplayback_internal var whiteSpacePreserved:Boolean;

		// used to manage opening and closing tags in openFontTag() and closeFontTags()
		flvplayback_internal var fontTagOpened:Object;
		flvplayback_internal var italicTagOpen:Boolean
		flvplayback_internal var boldTagOpen:Boolean;

		// used to iterate through attributes that apply to entire
		// caption cue point and not embedded in html tags in caption
		flvplayback_internal static var CAPTION_LEVEL_ATTRS:Array = [ "backgroundColor", "backgroundColorAlpha", "wrapOption" ]; 

		// namespaces
		flvplayback_internal var xmlNamespace:Namespace;
		flvplayback_internal var xmlns:Namespace;
		flvplayback_internal var tts_style:Namespace;
		flvplayback_internal var tts_styling:Namespace;
		flvplayback_internal var ttp:Namespace;

		/**
		 * constructor
		 */
		public function TimedTextManager(owner:FLVPlaybackCaptioning) {
			this.owner = owner;
			styleCounter = 1;
			xmlNamespace = new Namespace("http://www.w3.org/XML/1998/namespace");
		} 

		/**
		 * <p>Starts download of XML file.  Will be parsed and based
		 * on that we will decide how to connect.</p>
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function load(url:String):void {
			_url = url;

			if (xmlLoader != null) {
				// if loader already exists, close any current load
				try {
					xmlLoader.close();
				} catch (e:Error) {
				}
			} else {
				// create new loader and add event listeners
				xmlLoader = new URLLoader();
				xmlLoader.addEventListener(Event.COMPLETE, xmlLoadEventHandler);
				xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadEventHandler);
				xmlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadEventHandler);
				xmlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, owner.forwardEvent);
				xmlLoader.addEventListener(Event.OPEN, owner.forwardEvent);
				xmlLoader.addEventListener(ProgressEvent.PROGRESS, owner.forwardEvent);
			}

			xmlLoader.load(new URLRequest(_url));
		}

		/**
		 * <p>Handles load of XML.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function xmlLoadEventHandler(e:Event):void {
			try {
				if (e.type != Event.COMPLETE) {
					//ifdef DEBUG
					//debugTrace("xmlLoadEventHandler error event: " + e.type);
					//endif
					owner.forwardEvent(e);
				} else {
					flvPlayback = owner.flvPlayback;
					videoPlayerIndex = owner.videoPlayerIndex;
					limitFormatting = owner.simpleFormatting;
					styleStack = new Array();
					definedStyles = new Object();
					var cacheIgnoreWhitespace:Boolean = XML.ignoreWhitespace;
					var cachePrettyPrintint:Boolean = XML.prettyPrinting;
					var xmlStr:String = xmlLoader.data.replace(/\s+$/, "");
					xmlStr = xmlStr.replace(/>\s+</g, "><");
					xmlStr = xmlStr.replace(/\r\n/g, "\n");
					XML.ignoreWhitespace = false;
					XML.prettyPrinting = false;
					xml = new XML(xmlStr);
					XML.ignoreWhitespace = cacheIgnoreWhitespace;
					XML.prettyPrinting = cachePrettyPrintint;

					// making enforcement of the namespace loose in case people
					// fail to use http://www.w3.org/2006/04/ttaf1 or use some
					// future version of timed text with a different namespace
					//default xml namespace = "http://www.w3.org/2006/04/ttaf1";
					default xml namespace = xml.namespace();
					xmlns = xml.namespace();
					tts_style = new Namespace(xmlns.uri + "#style");
					tts_styling = new Namespace(xmlns.uri + "#styling");
					ttp = new Namespace(xmlns.uri + "#parameter");

					if (xml == null || xml.localName() == null) {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" No root node found");
					} else if (xml.localName() != "tt") {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Root node not tt");
					}

					// handle attributes
					var timeBaseAttr:XMLList = xml.@ttp::timeBase;
					if (timeBaseAttr.length() > 0 && timeBaseAttr[0].toString() != "media") {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Invalid value for ttp:timeBase attribute.  Only \"media\" supported, found \"" + timeBaseAttr[0].toString() + "\"");
					}
					whiteSpacePreserved = (getSpaceAttribute(xml) == "preserve");

					checkForIllegalElements(xml, {head: true, body: true});
					var headTags:XMLList = xml.head;
					var headTagsLen:int = headTags.length();
					if (headTagsLen > 1) {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Multiple head tags in " + xml.localName() + " tag.");
					} else if (headTagsLen > 0) {
						parseHead(headTags[0]);
					}
					var bodyTags:XMLList = xml.body;
					var bodyTagsLen:int = bodyTags.length();
					if (bodyTagsLen < 1) {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag body is required.");
					} else if (bodyTagsLen > 1) {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Multiple body tags in " + xml.localName() + " tag.");
					} else {
						parseBody(bodyTags[0]);
					}
					//ifdef DEBUG
					//debugTrace("xmlLoadEventHandler suceeded");
					//endif
					owner.forwardEvent(e);
				}
			} catch (err:Error) {
				//ifdef DEBUG
				//debugTrace("xmlLoadEventHandler error: " + err);
				//endif
				throw err;
			} finally {
				xmlLoader.removeEventListener(Event.COMPLETE, xmlLoadEventHandler);
				xmlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlLoadEventHandler);
				xmlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadEventHandler);
				xmlLoader = null;
			}
		}

		/**
		 * parse head node of tt
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseHead(parentNode:XML):void {
			//ifdef DEBUG
			//debugTrace("Parsing head tag...");
			//endif
			checkForIllegalElements(parentNode, {metadata: true, styling: true, layout: true});

			var metadataTags:XMLList = parentNode.metadata;
			if (metadataTags.length() > 1) {
				throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Multiple metadata tags in " + parentNode.localName() + " tag.");
			}

			var stylingTags:XMLList = parentNode.styling;
			var stylingTagsLen:int = stylingTags.length();
			if (stylingTagsLen > 1) {
				throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Multiple styling tags in " + parentNode.localName() + " tag.");
			} else if (stylingTagsLen > 0) {
				parseStyling(stylingTags[0]);
			}

			var layoutTags:XMLList = parentNode.layout;
			if (layoutTags.length() > 1) {
				throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Multiple layout tags in " + parentNode.localName() + " tag.");
			}
			//ifdef DEBUG
			//debugTrace("Done parsing head tag...");
			//endif
		}

		/**
		 * parse styling node of tt
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseStyling(parentNode:XML):void {
			//ifdef DEBUG
			//debugTrace("Parsing styling tag...");
			//endif
			checkForIllegalElements(parentNode, {metadata: true, style: true});
			var styleTags:XMLList = parentNode.style;
			var styleTagsLen:int = styleTags.length();
			for (var i:int = 0; i < styleTagsLen; i++) {
				var styleNode:XML = styleTags[i];
				var idAttr:XMLList = styleNode.@id;
				if (idAttr.length() < 1) {
					idAttr = styleNode.@xmlNamespace::id;
					if (idAttr.length() < 1) {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" Tag " + parentNode.localName() + " requires attribute id.");
					}
				}
				//ifdef DEBUG
				//debugTrace("Style with id " + idAttr.toString());
				//endif
				var styleObj:Object = new Object();
				//ifdef DEBUG
				//if (definedStyles[idAttr.toString()] != undefined) {
				//	debugTrace("Style " + styleNode.@id + " already defined!");
				//}
				//endif
				definedStyles[idAttr.toString()] = styleObj;
				parseStyleAttribute(styleNode, styleObj);
				parseTTSAttributes(styleNode, styleObj);
			}
			//ifdef DEBUG
			//debugTrace("Done parsing styling tag...");
			//endif
		}

		/**
		 * parse body node of tt
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseBody(parentNode:XML):void {
			//ifdef DEBUG
			//debugTrace("Parsing body tag...");
			//endif
			checkForIllegalElements(parentNode, {metadata: true, set: true, div: true});

			// create body style and push on stack
			var styleObj:Object = new Object();
			pushStyle(styleObj);
			parseStyleAttribute(parentNode, styleObj);
			parseTTSAttributes(parentNode, styleObj);

			// override parent tag xml:space if specified
			var spaceVal:String = getSpaceAttribute(parentNode);
			if (spaceVal != null) {
				whiteSpacePreserved = (spaceVal == "preserve");
			}

			var divTags:XMLList = parentNode.div;
			if (divTags.length() < 1) {
				//ifdef DEBUG
				//debugTrace("Done parsing body tag...");
				//endif
				popStyle();
				return;
			}

			//ifdef DEBUG
			//debugTrace("Parsing first div tag only...");
			//endif
			var divNode:XML = divTags[0];
			checkForIllegalElements(divNode, {p: true});

			// create div style and push on stack
			styleObj = new Object();
			pushStyle(styleObj);

			parseStyleAttribute(divNode, styleObj);
			parseTTSAttributes(divNode, styleObj);

			// override parent tag xml:space if specified
			spaceVal = getSpaceAttribute(divNode);
			if (spaceVal != null) {
				whiteSpacePreserved = (spaceVal == "preserve");
			}

			var pTags:XMLList = divNode.p;
			var pTagsLen:int = pTags.length();
			for (var i:int = 0; i < pTagsLen; i++) {
				parseParagraph(pTags[i]);
			}

			// fix and add last start tag if necessary, no duration or ending
			if (lastCuePoint != null) {
				delete lastCuePoint.parameters.endTime;
				var cacheActiveVideoPlayerIndex:uint = flvPlayback.activeVideoPlayerIndex;
				flvPlayback.activeVideoPlayerIndex = videoPlayerIndex;
				flvPlayback.addASCuePoint(lastCuePoint);
				flvPlayback.activeVideoPlayerIndex = cacheActiveVideoPlayerIndex;
				lastCuePoint = null;
			}

			// pop div style
			popStyle();

			//ifdef DEBUG
			//debugTrace("Done parsing first div tag only...");
			//endif

			// pop body style
			popStyle();

			//ifdef DEBUG
			//debugTrace("Done parsing body tag...");
			//endif
		}

		flvplayback_internal function parseParagraph(parentNode:XML):void {
			//ifdef DEBUG
			//debugTrace("Parsing p tag...");
			//endif

			// create paragraph style and push on stack
			var styleObj:Object = new Object();
			pushStyle(styleObj);
			parseStyleAttribute(parentNode, styleObj);
			parseTTSAttributes(parentNode, styleObj);

			var cacheWhiteSpacePreserved:Boolean = whiteSpacePreserved;

			// cue point objects
			var cuePoint:Object;
			
			var cacheActiveVideoPlayerIndex:uint = flvPlayback.activeVideoPlayerIndex;
			flvPlayback.activeVideoPlayerIndex = videoPlayerIndex;

			try {
				// override parent tag xml:space if specified
				var spaceVal:String = getSpaceAttribute(parentNode);
				if (spaceVal != null) {
					whiteSpacePreserved = (spaceVal == "preserve");
				}

				// setup cue points and times
				var beginTime:Number = parseTimeAttribute(parentNode, "begin", true);
				var endTime:Number = parseTimeAttribute(parentNode, "end", false);
				var duration:Number = parseTimeAttribute(parentNode, "dur", false);
				//ifdef DEBUG
				//debugTrace("beginTime = " + beginTime);
				//debugTrace("endTime = " + endTime);
				//debugTrace("duration = " + duration);
				//endif
				if (isNaN(beginTime)) {
					//ifdef DEBUG
					//debugTrace("Encountered p tag with no 'begin' attribute: " + parentNode);
					//endif
					return;
				} else {
					var nameID:uint = ++nameCounter;
					cuePoint = { time: beginTime, name: ("fl.video.caption.2.0." + nameID) };
					cuePoint.parameters = { id: nameID, url: _url};
				}
				if (isNaN(endTime) && !isNaN(duration)) {
					endTime = beginTime + duration;
				}

				// deal with setting endTime of previous caption if necessary
				if (lastCuePoint != null) {
					lastCuePoint.parameters.endTime = beginTime;
					flvPlayback.addASCuePoint(lastCuePoint);
					lastCuePoint = null;
				}

				// will these cue points need to be finished later?
				if (isNaN(endTime)) {
					lastCuePoint = cuePoint;
				} else {
					cuePoint.parameters.endTime = endTime;
				}

				// deal with other caption level attributes
				for (var h:int = 0; h < CAPTION_LEVEL_ATTRS.length; h++) {
					if (styleObj[CAPTION_LEVEL_ATTRS[h]] != undefined) {
						cuePoint.parameters[CAPTION_LEVEL_ATTRS[h]] = styleObj[CAPTION_LEVEL_ATTRS[h]];
					}
				}

				// init open tag tracking used by openFontTag() and closeFontTags()
				fontTagOpened = new Object();
				italicTagOpen = false;
				boldTagOpen = false;

				// start paragraph tag
				var captionText:String = (styleObj.textAlign == null) ? '<p>' : ('<p align="' + styleObj.textAlign + '">');

				// iterate over xml nodes, creating rest of caption text
				var children:XMLList = parentNode.children();
				for (var i:int = 0; i < children.length(); i++) {
					var child:XML = children[i];
					switch (child.nodeKind()) {
					case "text":
						captionText += openFontTag();
						captionText += fixCaptionText(child.toString());
						break;
					case "element":
						switch (child.localName()) {
						case "set":
						case "metadata":
							// ignore these tags
							break;
						case "span":
							captionText += parseSpan(child, cuePoint);
							break;
						case "br":
							captionText += "<br/>";
							break;
						default:
							captionText += fixCaptionText(child.toString());
							break;
						} // switch
						break;
					} // switch
				} // for

				// close up tags
				captionText += closeFontTags();
				captionText += "</p>";
				cuePoint.parameters.text = captionText;

				//ifdef DEBUG
				//debugTrace("captionText = " + captionText);
				//endif

				// add cue points if they are ready
				if (lastCuePoint == null) {
					flvPlayback.addASCuePoint(cuePoint);
				}

			} catch (e:Error) {
				//ifdef DEBUG
				//debugTrace("error in parseParagraph(): " + e.toString());
				//debugTrace(e.getStackTrace());
				//debugTrace("ignoring p tag : " + parentNode.toString());
				//endif
				lastCuePoint = null;
			} finally {
				flvPlayback.activeVideoPlayerIndex = cacheActiveVideoPlayerIndex;
				// pop paragraph style
				popStyle();
				// restore white space setting
				whiteSpacePreserved = cacheWhiteSpacePreserved;
			}

			//ifdef DEBUG
			//debugTrace("Done parsing p tag...");
			//endif
		}

		flvplayback_internal function parseSpan(parentNode:XML, cuePoint:Object):String {
			//ifdef DEBUG
			//debugTrace("Parsing span tag...");
			//endif

			// create span style and push on stack
			var styleObj:Object = new Object();
			pushStyle(styleObj);
			parseStyleAttribute(parentNode, styleObj);
			parseTTSAttributes(parentNode, styleObj);

			// override parent tag xml:space if specified
			var cacheWhiteSpacePreserved:Boolean = whiteSpacePreserved;
			var spaceVal:String = getSpaceAttribute(parentNode);
			if (spaceVal != null) {
				whiteSpacePreserved = (spaceVal == "preserve");
			}

			// deal with caption level attributes that can be found in span tag
			for (var h:int = 0; h < CAPTION_LEVEL_ATTRS.length; h++) {
				if (styleObj[CAPTION_LEVEL_ATTRS[h]] != undefined) {
					cuePoint.parameters[CAPTION_LEVEL_ATTRS[h]] = styleObj[CAPTION_LEVEL_ATTRS[h]];
				}
			}

			// get the text
			var captionText:String = openFontTag();
			var children:XMLList = parentNode.children();
			for (var i:int = 0; i < children.length(); i++) {
				var child:XML = children[i];
				switch (child.nodeKind()) {
				case "text":
					captionText += fixCaptionText(child.toString());
					break;
				case "element":
					switch (child.localName()) {
					case "set":
					case "metadata":
						// ignore these tags
						break;
					case "br":
						captionText += "<br/>";
						break;
					default:
						captionText += child.toString();
						break;
					} // switch
					break;
				} // switch
			} // for

			// pop span style
			popStyle();
			
			// restore white space setting
			whiteSpacePreserved = cacheWhiteSpacePreserved;

			//ifdef DEBUG
			//debugTrace("Done parsing span tag...");
			//endif

			return captionText;
		}

		flvplayback_internal function openFontTag():String {
			var tagText:String = "";

			// grab current style object
			var styleObj:Object = getStyle();

			// figure out what tags should be open
			var italicTag:Boolean, boldTag:Boolean;
			var nextFontTag:Object = new Object();
			for (var i:String in styleObj) {
				switch (i) {
				case "color":
					var strColor:String = styleObj[i].toString(16);
					while (strColor.length < 6) strColor = ("0" + strColor);
					nextFontTag.color = "#" + strColor;
					break;
				case "fontFamily":
					nextFontTag.face = styleObj[i];
					break;
				case "fontSize":
					nextFontTag.size = styleObj[i];
					break;
				case "fontStyle":
					italicTag = (styleObj[i] == "italic");
					break;
				case "fontWeight":
					boldTag = (styleObj[i] == "bold");
					break;
				}
			}

			// compare against current tags open and close current tags open if different
			if ( fontTagOpened.color != nextFontTag.color ||
			     fontTagOpened.face != nextFontTag.face ||
			     fontTagOpened.size != nextFontTag.size ) {
				tagText += closeFontTags();
				fontTagOpened = nextFontTag;
			}

			// open font tag if necessary
			if (fontTagOpened === nextFontTag) {
				var fontTagText:String = "<font ";
				for (var j:String in fontTagOpened) {
					fontTagText += (j + "=\"" + fontTagOpened[j] + "\" ");
				}
				if (fontTagText.length > 6) {
					// opening font tag should close with ">"
					tagText += (fontTagText + ">");
				}
			}

			// close bold tag if necessary
			if (boldTagOpen && !boldTag) tagText += "</b>";

			// open italic tag if necessary
			if (italicTagOpen && !italicTag) tagText += "</i>";

			// open italic tag if necessary
			if (!italicTagOpen && italicTag) tagText += "<i>";

			// open bold tag if necessary
			if (!boldTagOpen && boldTag) tagText += "<b>";

			// set italic and bold openness flags
			italicTagOpen = italicTag;
			boldTagOpen = boldTag;

			return tagText;
		}

		flvplayback_internal function closeFontTags():String {
			var tagText:String = "";
			if (boldTagOpen) tagText += "</b>";
			if (italicTagOpen) tagText += "</i>";
			if ( fontTagOpened.color != undefined ||
			     fontTagOpened.face != undefined ||
			     fontTagOpened.size != undefined ) {
				tagText += "</font>";
			}
			fontTagOpened = null;
			boldTagOpen = false;
			italicTagOpen = false;
			return tagText;
		}

		flvplayback_internal function parseStyleAttribute(xmlNode:XML, styleObj:Object):void {
			var idStr:String = null;
			var idAttr:XMLList = xmlNode.@id;
			if (idAttr.length() > 0) {
				idStr = idAttr.toString();
			}
			var styleAttr:XMLList = xmlNode.@style;
			if (styleAttr.length() > 0) {
				var styles:Array = styleAttr.toString().split(" ");
				for (var j:int = 0; j < styles.length; j++) {
					if (styles[j].length < 1) continue;
					//ifdef DEBUG
					//debugTrace("  Has style: " + styles[j]);
					//debugTrace("  Defined " + definedStyles[styles[j]]);
					//for (var db:* in definedStyles[styles[j]]) {
					//	debugTrace("    " + db + " = " + definedStyles[styles[j]][db]);
					//}
					//endif
					if (styles[j] == idStr) {
						//ifdef DEBUG
						//debugTrace("Tag ID and style ID conflict: " + styles[j]);
						//endif
					} else if (definedStyles[styles[j]] != undefined) {
						copyStyleObjectProps(styleObj, definedStyles[styles[j]]);
					}
					//ifdef DEBUG
					//else debugTrace("Style " + styles[j] + " undefined!");
					//endif
				}
			}
		}

		/**
		 * Extracts supported style attributes (tts:... attributes
		 * in namespace http://www.w3.org/2006/04/ttaf1#styling)
		 * or namespace http://www.w3.org/2006/04/ttaf1#style)
         * from an XMLList of attributes for a tag element.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseTTSAttributes(xmlNode:XML, styleObject:Object):void {
			parseTTSAttributesForNS(xmlNode, styleObject, tts_styling);
			parseTTSAttributesForNS(xmlNode, styleObject, tts_style);
		}

		flvplayback_internal function parseTTSAttributesForNS(xmlNode:XML, styleObject:Object, ns:Namespace):void {
			var attrs:XMLList = xmlNode.@ns::*;
			var attrsLen:int = attrs.length();
			for (var i:int = 0; i < attrsLen; i++) {
				var attr:XML = attrs[i];
				var localName:String = attr.localName();
				if (attr.toString() == "inherit") continue;
				switch (localName) {
				case "backgroundColor":
				case "color":
					if (limitFormatting) break;
					var colorObj:Object;
					try {
						colorObj = parseColor(attr.toString());
						//ifdef DEBUG
						//debugTrace("Got color 0x" + colorObj.colorInt.toString(16));
						//debugTrace("Got alphaZero " + colorObj.alphaZero);
						//endif
						styleObject[localName] = colorObj.colorInt;
						styleObject[localName + "Alpha"] = colorObj.alphaZero;
					} catch (e:Error) {
						//ifdef DEBUG
						//debugTrace("Error in parseColor: " + e);
						//debugTrace(e.getStackTrace());
						//endif
					}
					break;
				case "fontStyle":
				case "fontWeight":
					styleObject[localName] = attr.toString();
					break;
				case "fontSize":
					if (limitFormatting) break;
					var fontSize:String;
					try {
						fontSize = parseFontSize(attr.toString());
						//ifdef DEBUG
						//debugTrace("Got fontSize " + fontSize);
						//endif
						styleObject[localName] = fontSize;
					} catch (e:Error) {
						//ifdef DEBUG
						//debugTrace("Error in parseFontSize: " + e);
						//debugTrace(e.getStackTrace());
						//endif
					}
					break;
				case "fontFamily":
					if (limitFormatting) break;
					var fontFamily:String;
					try {
						fontFamily = parseFontFamily(attr.toString());
						//ifdef DEBUG
						//debugTrace("Got fontFamily " + fontFamily);
						//endif
						styleObject[localName] = fontFamily;
					} catch (e:Error) {
						//ifdef DEBUG
						//debugTrace("Error in parseFontFamily: " + e);
						//debugTrace(e.getStackTrace());
						//endif
					}
					break;
				case "textAlign":
					switch (attr.toString()) {
					case "left":
					case "right":
					case "center":
						styleObject[localName] = attr.toString();
						break;
					case "start":
						styleObject[localName] = "left";
						break;
					case "end":
						styleObject[localName] = "right";
						break;
					}
					break;

				case "wrapOption":
					if (limitFormatting) break;
					switch (attr.toString()) {
					case "wrap":
						styleObject[localName] = true;
						break;
					case "noWrap":
						styleObject[localName] = false;
						break;
					}
					break;
				default:
					//ifdef DEBUG
					//debugTrace("  Saw UNsupported attribute " + localName + " : " + attr.toString());
					//endif
					break;
				} // switch
			} // for
		}

		flvplayback_internal function getStyle():Object {
			if (styleStack.length > 0) {
				return styleStack[styleStack.length - 1];
			}
			return null;
		}

		flvplayback_internal function pushStyle(styleObj:Object):void {
			var prevStyle:Object = getStyle();
			if (prevStyle != null) {
				copyStyleObjectProps(styleObj, prevStyle);
			}
			styleStack.push(styleObj);
		}

		flvplayback_internal function popStyle():void {
			if (styleStack.length > 0) {
				styleStack.pop();
			}
		}

		/**
         * copies attributes from one style object to another
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function copyStyleObjectProps(tgt:Object, src:Object):void {
			for (var i:* in src) {
				tgt[i] = src[i];
			}
		}

		/**
         * parses color
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseColor(colorStr:String):Object {
			var theMatch:Object;
			var colorInt:uint = 0;
			var alphaZero:Boolean = false;
			if ( (theMatch = /^\s*#([\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f])([\dA-Fa-f][\dA-Fa-f])?\s*$/.exec(colorStr)) != null ) {
				colorInt = uint(parseInt(theMatch[1], 16));
				alphaZero = (theMatch[2] == "00");
			} else if ( (theMatch = /^\s*rgb(a)?\((\d+),(\d+),(\d+)(\)|(,(\d+)\)))\s*$/.exec(colorStr)) != null) {
				colorInt = (uint(parseInt(theMatch[2])) << 16) + (uint(parseInt(theMatch[3])) << 8) + uint(parseInt(theMatch[4]));
				alphaZero = (theMatch[1] == "a" && Number(theMatch[7] == 0));
			} else {
				switch (colorStr) {
				case "transparent":
					colorInt = 0x000000;
					alphaZero = true;
					break;
				case "black":
					colorInt = 0x000000;
					break;
				case "silver":
					colorInt = 0xc0c0c0;
					break;
				case "gray":
					colorInt = 0x808080;
					break;
				case "white":
					colorInt = 0xffffff;
					break;
				case "maroon":
					colorInt = 0x800000;
					break;
				case "red":
					colorInt = 0xff0000;
					break;
				case "purple":
					colorInt = 0x800080;
					break;
				case "fuchsia":
				case "magenta":
					colorInt = 0xff00ff;
					break;
				case "green":
					colorInt = 0x008000;
					break;
				case "lime":
					colorInt = 0x00ff00;
					break;
				case "olive":
					colorInt = 0x808000;
					break;
				case "yellow":
					colorInt = 0xffff00;
					break;
				case "navy":
					colorInt = 0x000080;
					break;
				case "blue":
					colorInt = 0x0000ff;
					break;
				case "teal":
					colorInt = 0x008080;
					break;
				case "aqua":
				case "cyan":
					colorInt = 0x00ffff;
					break;
				default:
					throw new TypeError("Invalid color value");
					break;
				} //switch
			}
			return {colorInt:colorInt, alphaZero:alphaZero};
		}

		/**
         * parses fontSize
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseFontSize(sizeStr:String):String {
			var theMatch:Object;
			if ( /^\s*\d+%.*$/.exec(sizeStr) != null) {
				// ingore percentage size
				throw new TypeError("Percentage fontSize not accepted");
			} else if ( (theMatch = /^\s*([\+\-]?\d+).*$/.exec(sizeStr)) != null ) {
				return theMatch[1];
			}
			throw new TypeError("Invalid fontSize");
		}

		/**
         * parses fontFamily
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseFontFamily(familyStr:String):String {
			var newFamilyStr:String = "";
			while (true) {
				var theMatch:Object = /^\s*([^,\s]+)\s*((,\s*([^,\s]+)\s*)*)$/.exec(familyStr);
				if (theMatch == null) {
					break;
				}
				if (newFamilyStr.length > 0) newFamilyStr += ",";
				switch (theMatch[1]) {
				case "monospace":
				case "monospaceSansSerif":
				case "monospaceSerif":
					newFamilyStr += "_typewriter";
					break;
				case "sansSerif":
				case "proportionalSansSerif":
					newFamilyStr += "_sans";
					break;
				case "default":
				case "serif":
				case "proportionalSerif":
					newFamilyStr += "_serif";
					break;
				default:
					newFamilyStr += theMatch[1];
					break;
				} // switch
				if (theMatch[2] != undefined && theMatch[2] != "") {
					familyStr = theMatch[2].slice(1);
				} else {
					break;
				}
			} // while (true)

			return newFamilyStr;
		}

		/**
		 * parse time in hh:mm:ss.s or mm:ss.s format.
		 * Also accepts a bare number of seconds with
		 * no colons.  Returns a number of seconds.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function parseTimeAttribute(parentNode:XML, attr:String, req:Boolean):Number {
			if (parentNode["@" + attr].length() < 1) {
				if (req) {
					throw new VideoError(VideoError.INVALID_XML, "Missing required attribute " + attr);
				}
				return NaN;
			}
			var timeStr:String = parentNode["@" + attr].toString();

			// first check for clock format or partial clock format
			var theTime:Number, multiplier:Number;
			var results:Object = /^((\d+):)?(\d+):((\d+)(.\d+)?)$/.exec(timeStr);
			if (results != null) {
				theTime = 0;
				theTime += (uint(results[2]) * 60 * 60);
				theTime += (uint(results[3]) * 60);
				theTime += (Number(results[4]));
				return theTime;
			}

			// next check for offset time
			results = /^(\d+(.\d+)?)(h|m|s|ms)?$/.exec(timeStr);
			if (results != null) {
				switch (results[3]) {
				case "h": multiplier = 3600; break;
				case "m": multiplier = 60; break;
				case "ms": multiplier = .001; break;
				case "s":
				default:
					multiplier = 1;
					break;
				}
				theTime = Number(results[1]) * multiplier;
				return theTime;
			}

			// as a last ditch we treat a bare number as seconds
			theTime = Number(timeStr);
			if (isNaN(theTime) || theTime < 0) {
				if (req) {
					throw new VideoError(VideoError.INVALID_XML, "Illegal time value " + timeStr + " for required attribute " + attr);
				}
				//ifdef DEBUG
				//else {
				//	debugTrace("Ignoring p tag with no illegal " + attr + " attribute: " + timeStr);
				//}
				//endif
				return NaN;
			}
			return theTime;
		}

		/**
		 * checks for extra, unrecognized elements of the given kind
		 * in parentNode and throws VideoError if any are found.
		 * Ignores any nodes with different nodeKind().  Takes the
		 * list of recognized elements as a parameter.
		 *
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function checkForIllegalElements(parentNode:XML, legalNodes:Object):void {
			var children:XMLList = parentNode.children();
			var childrenLen:int = children.length();
			var legalCount:int = 0;
			for (var i:String in legalNodes) {
				legalCount += parentNode[i].length();
			}
			if (legalCount != childrenLen) {
				// now search for specific illegal child
				for (var j:int = 0; j < childrenLen; j++) {
					var child:XML = children[j];
					if (child.nodeKind() != "element") continue;
					var childName:String = child.localName();
					if (!legalNodes[childName]) {
						throw new VideoError(VideoError.INVALID_XML, "URL: \"" + _url + "\" element " + childName + " not supported in " + parentNode.localName() + " tag.");
					}
				}
			}
		}

		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function fixCaptionText(inText:String):String {
			var outText:String = inText.replace(/(\\[Uu])([0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f])/g, unicodeEscapeReplace);
			if (!whiteSpacePreserved) {
				outText = outText.replace(/\s+/g, " ");
			}
			return outText;
		}

		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function unicodeEscapeReplace(match:String, first:String, second:String, index:int, all:String):String {
			return String.fromCharCode(Number("0x" + second));
		}

		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		flvplayback_internal function getSpaceAttribute(node:XML):String {
			var spaceAttr:XMLList = node.@space;
			if (spaceAttr.length() < 1) {
				spaceAttr = node.@xmlNamespace::space;
				if (spaceAttr.length() < 1) {
					return null;
				}
			}
			return spaceAttr[0];
		}

		//ifdef DEBUG
		//public function debugTrace(s:*):void {
		//	trace(s);
		//}
		//endif

	} // class TimedTextManager

} // package fl.video

