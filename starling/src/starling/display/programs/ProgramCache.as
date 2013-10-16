/**
 * Author: mrchnk
 * Time: 19.06.13 16:18
 */
package starling.display.programs {

	import flash.display3D.Context3D;
	import flash.display3D.Program3D;

	import starling.display.shaders.IShader;
	import starling.utils.Cache;

	/**
	 * Cache for Program3D
	 * Instead of Program3DCache caches different programs for different 3d contexts
	 */
	public class ProgramCache extends Cache {

		static private var _cache : ProgramCache = new ProgramCache();

		public function ProgramCache() {
			super( 3, true );
		}

		static public function getProgram3D( context : Context3D, vertexShader : IShader, fragmentShader : IShader ) : Program3D {
			return _cache.getProgram3D( context, vertexShader, fragmentShader );
		}

		public static function disposeProgram3D( vertexShader : IShader, fragmentShader : IShader ) : void {
			_cache.dispose( vertexShader, fragmentShader );
		}

		public function getProgram3D( context : Context3D, vertexShader : IShader, fragmentShader : IShader ) : Program3D {
			return getItem( context, vertexShader, fragmentShader ) as Program3D;
		}

		override protected function createItem( key : Vector.<Object> ) : Object {
			var context : Context3D = key[ 0 ] as Context3D;
			var vertexShader : IShader = key[ 1 ] as IShader;
			var fragmentShader : IShader = key[ 2 ] as IShader;
			var program : Program3D = context.createProgram();
			program.upload( vertexShader.opCode, fragmentShader.opCode );
			return program;
		}

		public function dispose( vertexShader : IShader, fragmentShader : IShader ) : void {
			disposeItems( null, vertexShader, fragmentShader );
		}

		override protected function disposeItem( item : Object ) : void {
			( item as Program3D ).dispose();
		}

	}

}
