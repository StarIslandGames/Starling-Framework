/**
 * Author: mrchnk
 * Time: 19.06.13 15:56
 */
package starling.display.programs {

	import flash.display3D.Context3DProgramType;

	import starling.display.shaders.AGALShader;

	public class AGALProgram extends Program {

		public function AGALProgram( vertexAgal : String, fragmentAgal : String ) {
			super( new AGALShader( Context3DProgramType.VERTEX, vertexAgal ), new AGALShader( Context3DProgramType.FRAGMENT, fragmentAgal ) );
		}

	}

}
