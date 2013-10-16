/**
 * Author: mrchnk
 * Time: 19.06.13 15:30
 */
package starling.display.programs {

	import flash.display3D.Context3D;

	public interface IProgram {

		function activate( context : Context3D ) : void;
		function dispose() : void;

	}

}
