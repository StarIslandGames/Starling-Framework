/**
 * Author: mrchnk
 * Time: 13.06.13 17:34
 */
package com.sig.starling {

	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.textures.ConcreteTexture;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	import starling.utils.MatrixUtil;
	import starling.utils.MatrixUtil;

	public class StarlingHitTest {

		private var _registeredTextures : Dictionary;
		static private const sHelperMatrix : Matrix = new Matrix();
		static private const sHelperPoint : Point = new Point();
		static private const sHelperRect : Rectangle = new Rectangle();
		static private const sOneRect : Rectangle = new Rectangle( 0, 0, 1, 1 );

		private static var _instance : StarlingHitTest;

		public function StarlingHitTest() {
			_registeredTextures = new Dictionary( true );
		}

		public static function get instance() : StarlingHitTest {
			if ( !_instance ) {
				_instance = new StarlingHitTest();
			}

			return _instance;
		}

		public function setHitTest( tex : Texture, testTexture : HitTestTexture ) : void {
			tex = tex.root;
			if ( tex ) {
				_registeredTextures[ tex ] = testTexture;
			}
		}

		public function hitTestTexture( tex : Texture, x : int, y : int ) : Boolean {
			if ( !tex ) {
				return false;
			}
			var testTexture : HitTestTexture = _registeredTextures[ tex.root ];
			if ( !testTexture ) {
				return false;
			}
			var p : Point = getRootTexturePosition( tex, x, y, sHelperPoint );
			if ( !p ) {
				return false
			}
			return testTexture.hitTest( p.x, p.y );
		}

		public function hitTestObject( obj : DisplayObject, x : int, y : int ) : Boolean {
			var container : DisplayObjectContainer = obj as DisplayObjectContainer;
			if ( container ) {
				var numChildren : int = container.numChildren;
				for ( var i : int = numChildren - 1; i >= 0; --i ) {
					var child : DisplayObject = container.getChildAt( i );
					container.getTransformationMatrix( child, sHelperMatrix );
					MatrixUtil.transformCoords( sHelperMatrix, x, y, sHelperPoint );
					if ( hitTestObject( child, sHelperPoint.x, sHelperPoint.y ) ) {
						return true;
					}
				}
				return false;
			}
			var image : Image = obj as Image;
			if ( image ) {
				return hitTestImage( image, x, y );
			}
			sHelperPoint.setTo( x, y );
			return obj.hitTest( sHelperPoint, true ) !== null;
		}

		public function hitTestImage( image : Image, x : int, y : int ) : Boolean {
			if ( !image.texture ) {
				return false;
			}
			if ( !image.getBounds( image, sHelperRect ).contains( x, y ) ) {
				return false;
			}
			return hitTestTexture( image.texture, x, y );
		}

		public static function getRootTexturePosition( tex : Texture, x : int, y : int, dst : Point = null ) : Point {
			if ( !dst ) {
				dst = new Point()
			}
			var subTexture : SubTexture = tex as SubTexture;
			while ( subTexture ) {
				var sx : Number, sy : Number;
				if ( subTexture.frame ) {
					x += subTexture.frame.x;
					y += subTexture.frame.y;
				}
				sx = x / tex.width;
				sy = y / tex.height;
				if ( !sOneRect.contains( sx, sy ) ) {
					return null;
				}
				MatrixUtil.transformCoords( subTexture.transformationMatrix, sx, sy, sHelperPoint );
				x = sHelperPoint.x * subTexture.parent.width;
				y = sHelperPoint.y * subTexture.parent.height;
				subTexture = subTexture.parent as SubTexture;
			}
			var root : ConcreteTexture = tex.root;
			dst.setTo( x * root.scale, y * root.scale );
			return dst;
		}

	}

}
