/**
 * Author: mrchnk
 * Time: 17.10.13 12:56
 */
package com.sig.starling {

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.core.starling_internal;
	import starling.display.BlendMode;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Stage;

	use namespace starling_internal;

	public class StarlingUtils {

		static private var _support : Dictionary = new Dictionary( true );
		static private var _helpMatrix : Matrix = new Matrix();
		static private var _helpRect : Rectangle = new Rectangle();
		static private var _pixelBitmap : BitmapData = new BitmapData( 1, 1, true, 0 );
		static private var _pixelRect : Rectangle = new Rectangle( 0, 0, 1, 1 );
		static private const ZERO_POINT : Point = new Point();
		static private const INVERT_COLOR : ColorMatrixFilter = new ColorMatrixFilter( [
			-1, 0, 0, 0, 255,
			0, -1, 0, 0, 255,
			0, 0, -1, 0, 255,
			0, 0, 0, 1, 0
		] );

		/**
		 * Render object to BitmapData
		 * Alpha works only in context3D profile BASELINE or BASELINE_EXTENDED
		 * @param source
		 * @param target
		 * @param sizing
		 * @param anchor
		 * @return false on fail
		 */
		public static function render( source : DisplayObject, target : BitmapData, tranform : Matrix = null, currentStarling : Starling = null ) : Boolean {
			if ( !tranform ) {
				_helpMatrix.identity();
				tranform = _helpMatrix;
			}
			return _render( source, target, target.rect, tranform, 0, 0, null, currentStarling );
		}

		/**
		 * Render object to BitmapData
		 * Works with context3D profile BASELINE_CONSTRAINED
		 * @param source
		 * @param target
		 * @param sizing
		 * @param anchor
		 * @return false on fail
		 */
		public static function renderWithAlpha( source : DisplayObject, target : BitmapData,  tranform : Matrix = null, currentStarling : Starling = null ) : Boolean {
			if ( !tranform ) {
				_helpMatrix.identity();
				tranform = _helpMatrix;
			}
			var rect : Rectangle = target.rect;
			if ( !_render( source, target, rect, tranform, 0, 0, null, currentStarling ) ) {
				return false;
			}
			var alphaBitmap : BitmapData = new BitmapData( target.width, target.height, false );
			if ( !_render( source, alphaBitmap, rect, tranform, 0xffffff, 1, BlendMode.ERASE ) ) {
				return false;
			}
			alphaBitmap.applyFilter( alphaBitmap, rect, ZERO_POINT, INVERT_COLOR );
			target.copyChannel( alphaBitmap, rect, ZERO_POINT, BitmapDataChannel.RED, BitmapDataChannel.ALPHA );
			return true;
		}

		/**
		 * Detect color of specified object's pixel
		 * Alpha works only in context3D profile BASELINE or BASELINE_EXTENDED
		 * @param display
		 * @param x
		 * @param y
		 * @return color in 0xAARRGGBB, 0 on fail
		 */
		public static function getPixelColor( display : DisplayObject, x : int, y : int ) : uint {
			_helpMatrix.identity();
			_helpMatrix.tx = -x;
			_helpMatrix.ty = -y;
			if ( !_render( display, _pixelBitmap, _pixelRect, _helpMatrix ) ) {
				return 0;
			}
			return _pixelBitmap.getPixel32( 0, 0 );
		}

		/**
		 * Detect alpha of specified object's pixel
		 * Works with context3D profile BASELINE_CONSTRAINED
		 * May (and will) not work with objects with blendMode != "auto" (and nested too)
		 * @param display
		 * @param x
		 * @param y
		 * @return alpha value 0..255, -1 on fail
		 */
		public static function getAlpha( display : DisplayObject, x : int, y : int ) : int {
			_helpMatrix.identity();
			_helpMatrix.tx = -x;
			_helpMatrix.ty = -y;
			if ( !_render( display, _pixelBitmap, _pixelRect, _helpMatrix, 0xffffff, 1, BlendMode.ERASE ) ) {
				return -1;
			}
			return 0xff - _pixelBitmap.getPixel( 0, 0 ) & 0xff;
		}

		private static function _getSupport() : RenderSupport {
			if ( !Starling.current ) {
				return null;
			}
			var support : RenderSupport = _support[ Starling.current ];
			if ( !support ) {
				support = _support[ Starling.current ] = new RenderSupport();
			}
			return support;
		}

		private static function _render( source : DisplayObject, target : BitmapData, clip : Rectangle = null, transform : Matrix = null, bgColor : uint = 0, bgAlpha : Number = 0, blendMode : String = null, currentStarling : Starling = null ) : Boolean {
			source.pushStarling();

			var mStage : Stage = Starling.current.stage;
			var _support : RenderSupport = _getSupport();
			_support.nextFrame();
			_support.setOrthographicProjection( 0, 0, mStage.stageWidth, mStage.stageHeight );
			try {
				_support.clear( bgColor, bgAlpha );
			} catch ( err : Error ) {
				source.popStarling();
				trace( "ERROR: StarlingUtils._render(): context is lost (" + err.toString() + ")" );
				return false;
			}
			var sourceBlendMode : String = source.blendMode;
			if ( blendMode ) {
				_support.blendMode = blendMode;
				source.blendMode = BlendMode.AUTO;
			}
			if ( transform ) {
				_support.pushMatrix();
				_support.prependMatrix( transform );
			}
			if ( clip ) {
				_support.pushClipRect( clip );
			}
			source.render( _support, 1 );
			_support.finishQuadBatch();
			if ( clip ) {
				_support.popClipRect();
			}
			if ( blendMode ) {
				_support.blendMode = BlendMode.NORMAL;
				source.blendMode = sourceBlendMode;
			}
			Starling.context.drawToBitmapData( target );
			source.popStarling();
			return true;
		}

		static public function addChildSilent( parent : DisplayObjectContainer, child : DisplayObject ) : void {
			if ( child.parent ) {
				removeChildSilent( child.parent, child );
			}
			parent.mChildren.push( child );
			child.mParent = parent;
		}

		static public function addChildSilentAt( parent : DisplayObjectContainer, child : DisplayObject, idx : int ) : void {
			if ( child.parent ) {
				removeChildSilent( child.parent, child );
			}
			var len : int = parent.mChildren.length + 1;
			parent.mChildren.length = len;
			for ( var i : int = idx + 1; i < len; i++ ) {
				parent.mChildren[ i ] = parent.mChildren[ i - 1 ];
			}
			parent.mChildren[ idx ] = child;
			child.mParent = parent;
		}

		static public function changeChildSilent( parent : DisplayObjectContainer, curChild : DisplayObject, newChild : DisplayObject ) : void {
			curChild.mParent = null;
			parent.mChildren[ parent.mChildren.indexOf( curChild ) ] = newChild;
			newChild.mParent = parent;
		}

		static public function removeChildSilent( parent : DisplayObjectContainer, child : DisplayObject ) : void {
			child.mParent = null;
			var len : int = parent.mChildren.length - 1;
			for ( var i : int = parent.mChildren.indexOf( child ); i < len; i++ ) {
				parent.mChildren[ i ] = parent.mChildren[ i + 1 ];
			}
			parent.mChildren.length = len;
		}

		public static function removeChildrenSilent( parent : DisplayObjectContainer ) : void {
			var len : int = parent.mChildren.length;
			for ( var i : int = 0; i < len; i++ ) {
				parent.mChildren[ i ].mParent = null;
			}
			parent.mChildren.length = 0;
		}

	}

}
