/**
 * Author: mrchnk
 * Time: 13.06.13 15:56
 */
package com.sig.starling {

	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class HitTestTexture extends Object {

		static public function convertBitmapData( data : BitmapData, colorTestClosure : Function = null ) : ByteArray {
			var res : ByteArray = new ByteArray();
			var byte : uint = 0;
			var bat : uint = 1;
			var byteSize : uint = 0;
			for ( var x : uint = 0; x < data.width; x++ ) {
				for ( var y : uint = 0; y < data.height; y++ ) {
					var hit : Boolean = false;
					var color : uint = data.getPixel32( x, y );
					if ( colorTestClosure === null ) {
						hit = colorTest( color );
					} else {
						hit = colorTestClosure( color );
					}
					if ( hit ) {
						byte += bat;
					}
					byteSize++;
					if ( byteSize === 8 ) {
						res.writeByte( byte );
						byteSize = byte = 0;
						bat = 1;
					} else {
						bat <<= 1;
					}
				}
			}
			return res;
		}

		static public function fromBitmapData( data : BitmapData, colorTestClosure : Function = null ) : HitTestTexture {
			return new HitTestTexture( data.width, data.height, null, data, colorTestClosure );
		}

		static public function fromByteArray( width : int, height : int, data : ByteArray ) : HitTestTexture {
			return new HitTestTexture( width, height, data );
		}

		static public function fromBoolean( width : int, height : int, hitTest : Boolean ) : HitTestTexture {
			return new HitTestTexture( width, height, null, null, null, hitTest );
		}

		[Inline]
		static private function colorTest( color : uint ) : Boolean {
			return ( color & 0xf8000000 ) !== 0;
		}

		private var _width : uint;
		private var _height : uint;
		private var _bytes : ByteArray;
		private var _bitmap : BitmapData;
		private var _colorTestClosure : Function;
		private var _emptyHit : Boolean;

		public function HitTestTexture( width : int, height : int, bytes : ByteArray = null, bitmap : BitmapData = null, colorTestClosure : Function = null, emptyHit : Boolean = false ) {
			_width = width;
			_height = height;
			_bytes = bytes;
			_bitmap = bitmap;
			_colorTestClosure = colorTestClosure;
			_emptyHit = emptyHit;
		}

		public function hitTest( x : int, y : int ) : Boolean {
			if ( ( x >= _width ) || ( x < 0 ) || ( y >= _height ) || ( y < 0 ) ) {
				return false;
			}
			if ( _bitmap ) {
				var color : uint;
				if ( _colorTestClosure !== null ) {
					color = _bitmap.getPixel32( x, y );
					return _colorTestClosure( color );
				}
				if ( _bitmap.transparent ) {
					color = _bitmap.getPixel32( x, y );
					return colorTest( color );
				}
				return true;
			}
			if ( _bytes ) {
				var pixelNum : uint = x * _height + y;
				var pos : uint = pixelNum >>> 3;
				var bytePos : uint = pixelNum - (pos << 3);
				var byteMask : uint = 1 << bytePos;
				var byte : uint = _bytes[ pos ];
				return ( byte & byteMask ) !== 0;
			}
			return _emptyHit;
		}

		public function setHitTest( x : int, y : int, value : Boolean ) : void {
			if ( ( x >= _width ) || ( x < 0 ) || ( y >= _height ) || ( y < 0 ) ) {
				return;
			}
			var pixelNum : uint = x * _height + y;
			var pos : uint = pixelNum >>> 3;
			var bytePos : uint = pixelNum - (pos << 3);
			var byteMask : uint = 1 << bytePos;
			_bytes.position = pos;
			var byte : uint = _bytes.readUnsignedByte();
			_bytes.position = pos;
			if ( value ) {
				byte |= byteMask;
			} else {
				byte &= 1 - byteMask;
			}
			_bytes.writeByte( byte );
		}

		public function draw( dst : BitmapData = null, clrHit : uint = 0xffffffff, clrEmpty : uint = 0xff000000 ) : BitmapData {
			if ( !dst ) {
				dst = new BitmapData( _width, _height, true );
			}
			for ( var x : uint = 0; x < _width; x++ ) {
				for ( var y : uint = 0; y < _height; y++ ) {
					dst.setPixel32( x, y, hitTest( x, y ) ? clrHit : clrEmpty );
				}
			}
			return dst;
		}

	}

}
