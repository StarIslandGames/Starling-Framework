/**
 * Author: mrchnk
 * Time: 19.06.13 17:18
 */
package starling.display.buffers {

	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;

	import starling.utils.Cache;

	public class BufferCache extends Cache {

		static private var _cache : BufferCache = new BufferCache();

		public function BufferCache() : void {
			super( 2, true );
		}

		public static function getIndex( context : Context3D, buffer : IBuffer ) : IndexBuffer3D {
			return _cache.getIndex( context, buffer );
		}

		public static function getVertex( context : Context3D, buffer : IBuffer ) : VertexBuffer3D {
			return _cache.getVertex( context, buffer );
		}

		public static function dispose( buffer : IBuffer ) : void {
			_cache.disposeItems( null, buffer );
		}

		override protected function createItem( key : Vector.<Object> ) : Object {
			var context : Context3D = key[ 0 ] as Context3D;
			var buffer : IBuffer = key[ 1 ] as IBuffer;

			var index : IndexBuffer3D = context.createIndexBuffer( buffer.indexData.length );
			index.uploadFromVector( buffer.indexData, 0, buffer.indexData.length );

			var numVertices : uint = buffer.vertexData.length / buffer.dataPerVertex;
			var vertex : VertexBuffer3D = context.createVertexBuffer( numVertices, buffer.dataPerVertex );
			vertex.uploadFromVector( buffer.vertexData, 0, numVertices );

			return [ index, vertex ];
		}

		public function getIndex( context : Context3D, buffer : IBuffer ) : IndexBuffer3D {
			return getItem( context, buffer )[ 0 ];
		}

		public function getVertex( context : Context3D, buffer : IBuffer ) : VertexBuffer3D {
			return getItem( context, buffer )[ 1 ];
		}

		override protected function disposeItem( item : Object ) : void {
			( item[ 0 ] as IndexBuffer3D ).dispose();
			( item[ 1 ] as VertexBuffer3D ).dispose();
			item.length = 0;
		}

	}

}
