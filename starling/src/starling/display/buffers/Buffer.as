/**
 * Author: mrchnk
 * Time: 19.06.13 17:16
 */
package starling.display.buffers {

	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;

	public class Buffer extends Object implements IBuffer {

		private var _vertexData : Vector.<Number>;
		private var _dataPerVertex : uint;
		private var _indexData : Vector.<uint>;
		private var _disposed : Boolean = false;
		private var _vertexBufferInfos : Vector.<VertexBufferInfo> = new Vector.<VertexBufferInfo>();

		public function Buffer( vertexData : Vector.<Number>, dataPerVertex : uint, indexData : Vector.<uint> ) {
			_vertexData = vertexData;
			_dataPerVertex = dataPerVertex;
			_indexData = indexData;
		}

		public function dispose() : void {
			BufferCache.dispose( this );
			_vertexBufferInfos.length = 0;
			_disposed = true;
		}

		public function update() : void {
			BufferCache.dispose( this );
		}

		public function draw( context : Context3D ) : void {
			if ( _disposed ) {
				throw new Error( "Buffer is disposed" );
			}
			var indexBuffer : IndexBuffer3D = BufferCache.getIndex( context, this );
			var vertexBuffer : VertexBuffer3D = BufferCache.getVertex( context, this );
			var bufferInfo : VertexBufferInfo;
			for each ( bufferInfo in _vertexBufferInfos ) {
				context.setVertexBufferAt( bufferInfo.index, vertexBuffer, bufferInfo.offset, bufferInfo.format );
			}
			context.drawTriangles( indexBuffer );
			for each ( bufferInfo in _vertexBufferInfos ) {
				context.setVertexBufferAt( bufferInfo.index, null );
			}
		}

		public function setVertexBufferAt( index : uint, offset : uint, format : String ) : void {
			var bufferInfo : VertexBufferInfo;
			for each ( var bufferInfoIterator : VertexBufferInfo in _vertexBufferInfos ) {
				if ( bufferInfoIterator.index === index ) {
					bufferInfo = bufferInfoIterator;
					break;
				}
			}
			if ( !bufferInfo ) {
				bufferInfo = new VertexBufferInfo();
				_vertexBufferInfos.push( bufferInfo );
			}
			bufferInfo.index = index;
			bufferInfo.offset = offset;
			bufferInfo.format = format;
		}

		public function unsetVertexBufferAt( index : uint ) : void {
			for ( var i : int = 0; i < _vertexBufferInfos.length; i++ ) {
				var format : VertexBufferInfo = _vertexBufferInfos[ i ];
				if ( format.index === index ) {
					_vertexBufferInfos.splice( i, 1 );
					return;
				}
			}
		}

		public function clearFormat() : void {
			_vertexBufferInfos.length = 0;
		}

		public function get vertexData() : Vector.<Number> {
			return _vertexData;
		}

		public function get dataPerVertex() : uint {
			return _dataPerVertex;
		}

		public function get indexData() : Vector.<uint> {
			return _indexData;
		}
	}

}

class VertexBufferInfo extends Object {

	public var index : int;
	public var offset : int;
	public var format : String;

	public function VertexBufferInfo() {
	}

}