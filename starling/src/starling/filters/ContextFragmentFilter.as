/**
 * Author: mrchnk
 * Time: 19.06.13 15:11
 */
package starling.filters {

	import flash.display3D.Context3D;

	import starling.textures.Texture;

	public class ContextFragmentFilter extends FragmentFilter {

		public function ContextFragmentFilter() {
		}

		override protected function createPrograms() : void {
//			super.createPrograms();
		}

		protected /* virtual */ function createProgramsFor( context : Context3D ) : void {

		}

		protected /* virtual */ function disposeProgramsFor( context : Context3D ) : void {

		}

		override protected function activate( pass : int, context : Context3D, texture : Texture ) : void {
			super.activate( pass, context, texture );
		}
	}

}
