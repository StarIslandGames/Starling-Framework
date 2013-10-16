/**
 * Author: mrchnk
 * Time: 27.08.13 19:24
 */
package starling.text {

	import flash.display.BitmapData;
	import flash.utils.Dictionary;

	import starling.core.Starling;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.text.BitmapFont;
	import starling.text.MiniBitmapFont;
	import starling.textures.Texture;

	public class MultiStarlingBitmapFont extends BitmapFont {

		private var _texture : Texture;
		private var _fontTexture : BitmapData;
		private var _starlingToFont : Dictionary;

		static private var _mini : BitmapFont;

		public static function getMini() : BitmapFont {
			if ( !_mini ) {
				_mini = new MultiStarlingBitmapFont( MiniBitmapFont.bitmap, MiniBitmapFont.xml );
			}
			return _mini;
		}

		public function MultiStarlingBitmapFont( fontTexture : BitmapData, fontData : Object ) {
			super( _texture = Texture.empty( 16, 16 ), fontData );
			_fontTexture = fontTexture;
			_starlingToFont = new Dictionary( true );
		}

		override public function dispose() : void {
			for each ( var font : BitmapFont in _starlingToFont ) {
				font.dispose();
			}
		}

		override public function fillQuadBatch( quadBatch : QuadBatch, width : Number, height : Number, text : String, fontSize : Number = -1, color : uint = 0xffffff, hAlign : String = "center", vAlign : String = "center", autoScale : Boolean = true, kerning : Boolean = true ) : void {
			getChildFont( Starling.current ).fillQuadBatch( quadBatch, width, height, text, fontSize, color, hAlign, vAlign, autoScale, kerning );
		}

		override public function createSprite( width : Number, height : Number, text : String, fontSize : Number = -1, color : uint = 0xffffff, hAlign : String = "center", vAlign : String = "center", autoScale : Boolean = true, kerning : Boolean = true ) : Sprite {
			return getChildFont( Starling.current ).createSprite( width, height, text, fontSize, color, hAlign, vAlign, autoScale, kerning );
		}

		public function get chars() : Dictionary {
			return mChars;
		}

		public function onChildDispose( starling : Starling ) : void {
			delete _starlingToFont[ starling ];
		}

		private function getChildFont( starling : Starling ) : BitmapFont {
			if ( _starlingToFont[ starling ] ) {
				return _starlingToFont[ starling ];
			}
			var child : BitmapFont = _starlingToFont[ starling ] = new MultiStarlingBitmapFontChild( this, Texture.fromBitmapData( _fontTexture, false ), starling );
			return child;
		}

		public function get texture() : Texture {
			return _texture;
		}

	}

}


import flash.geom.Rectangle;
import flash.utils.Dictionary;

import starling.core.Starling;
import starling.text.BitmapChar;
import starling.text.BitmapFont;
import starling.text.MultiStarlingBitmapFont;
import starling.textures.SubTexture;
import starling.textures.Texture;

class MultiStarlingBitmapFontChild extends BitmapFont {

	private var _parent : MultiStarlingBitmapFont;
	private var _starling : Starling;
	private var _chars : Dictionary;
	private var _texture : Texture;

	public function MultiStarlingBitmapFontChild( parent : MultiStarlingBitmapFont, texture : Texture, starling : Starling ) {
		super( texture, null );
		_texture = texture;
		_chars = new Dictionary();
		_parent = parent;
		_starling = starling;
		mName = parent.name;
		mSize = parent.size;
		mLineHeight = parent.lineHeight;
		mBaseline = parent.baseline;
	}

	override public function get lineHeight() : Number {
		return _parent.lineHeight;
	}

	override public function set lineHeight( value : Number ) : void {
		_parent.lineHeight = value;
	}

	override public function set smoothing( value : String ) : void {
		_parent.smoothing = value;
	}

	override public function get smoothing() : String {
		return _parent.smoothing;
	}

	override public function dispose() : void {
		super.dispose();
		_parent.onChildDispose( _starling );
	}

	override public function getChar( charID : int ) : BitmapChar {
		if ( _chars[ charID ] ) {
			return _chars[ charID ];
		}
		var parentChar : BitmapChar = _parent.getChar( charID );
		if ( !parentChar ) {
			return null;
		}
		var childChar : BitmapChar = _chars[ charID ] = new BitmapCharChild( parentChar, _texture );
		return childChar;
	}

	override public function addChar( charID : int, bitmapChar : BitmapChar ) : void {
		_parent.addChar( charID, bitmapChar );
	}

}


class BitmapCharChild extends BitmapChar {

	private var _parent : BitmapChar;

	public function BitmapCharChild( parent : BitmapChar, texture : Texture ) {
		_parent = parent;
		var region : Rectangle = ( parent.texture as SubTexture ).clipping;
		var parentWidth : Number = ( parent.texture as SubTexture ).parent.width;
		var parentHeight : Number = ( parent.texture as SubTexture ).parent.height;
		region.x *= parentWidth;
		region.y *= parentHeight;
		region.width *= parentWidth;
		region.height *= parentHeight;
		texture = Texture.fromTexture( texture, region );
		super( parent.charID, texture, parent.xOffset, parent.yOffset, parent.xAdvance );
	}

	override public function getKerning( charID : int ) : Number {
		return _parent.getKerning( charID );
	}

}