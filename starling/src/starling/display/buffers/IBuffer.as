/**
 * Author: mrchnk
 * Time: 19.06.13 17:17
 */
package starling.display.buffers {


	public interface IBuffer {

		function get dataPerVertex() : uint;

		function get vertexData() : Vector.<Number>;

		function get indexData() : Vector.<uint>;

	}
}
