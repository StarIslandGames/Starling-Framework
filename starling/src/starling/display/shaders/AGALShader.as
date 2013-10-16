/**
 * Author: mrchnk
 * Time: 19.06.13 15:57
 */
package starling.display.shaders {

	public class AGALShader extends AbstractShader {

		public function AGALShader( shaderType : String, agal : String ) {
			compileAGAL( shaderType, agal );
		}

	}

}
