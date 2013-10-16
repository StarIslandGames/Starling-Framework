/**
 * Author: mrchnk
 * Time: 19.06.13 15:30
 */
package starling.display.programs {

	import flash.display3D.Context3D;
	import flash.display3D.Program3D;

	import starling.display.shaders.IShader;

	/**
	 * Helper class to provide Program3D in different context using IShader's and ProgramCache
	 */
	public class Program implements IProgram {

		private var _vertexShader : IShader;
		private var _fragmentShader : IShader;

		public function Program( vertexShader : IShader, fragmentShader : IShader ) {
			_vertexShader = vertexShader;
			_fragmentShader = fragmentShader;
		}

		public function activate( context : Context3D ) : void {
			var program : Program3D = ProgramCache.getProgram3D( context, _vertexShader, _fragmentShader );
			context.setProgram( program );
		}

		public function dispose() : void {
			ProgramCache.disposeProgram3D( _vertexShader, _fragmentShader );
		}

	}

}
