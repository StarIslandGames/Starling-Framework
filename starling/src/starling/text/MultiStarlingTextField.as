/**
 * Author: mrchnk
 * Time: 03.07.13 13:07
 */
package starling.text {

	import flash.utils.Dictionary;

	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.text.*;

	public class MultiStarlingTextField extends TextField {

		static private const registeredBitmapFonts : Dictionary = new Dictionary();
		private var _lastRedrawStarling : Starling;

		public function MultiStarlingTextField( width : int, height : int, text : String, fontName : String = "Verdana", fontSize : Number = 12, color : uint = 0x0, bold : Boolean = false ) {
			super( width, height, text, fontName, fontSize, color, bold );
		}

		override public function render( support : RenderSupport, parentAlpha : Number ) : void {
			if ( Starling.current !== _lastRedrawStarling ) {
				mRequiresRedraw = true;
			}
			super.render( support, parentAlpha );
		}

		override public function redraw() : void {
			if ( !stage ) {
				return;
			}
			_lastRedrawStarling = Starling.current;
			super.redraw();
		}

		override protected function _getBitmapFont( name : String ) : BitmapFont {
			if ( registeredBitmapFonts[ name ] ) {
				return registeredBitmapFonts[ name ];
			}
			if ( name === BitmapFont.MINI ) {
				return MultiStarlingBitmapFont.getMini();
			}
			return null;
		}

		static public function registerFont( font : BitmapFont ) : void {
			registeredBitmapFonts[ font.name ] = font;
		}

		static public function unregisterFont( font : BitmapFont ) : void {
			if ( registeredBitmapFonts[ font.name ] ) {
				delete registeredBitmapFonts[ font.name ];
				font.dispose();
			}
		}

		public function requireRedraw() : void {
			mRequiresRedraw = true;
		}
	}

}
