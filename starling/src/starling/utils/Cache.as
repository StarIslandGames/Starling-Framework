/**
 * Author: mrchnk
 * Time: 05.07.13 12:54
 */
package starling.utils {

	public class Cache {

		private var _keyLength : int;
		private var _cache : OneKeyCache = new OneKeyCache();
		private var _temp : Vector.<Object> = new Vector.<Object>();
		private var _autoCreate : Boolean;

		public function Cache( keyLength : int = 1, autoCreate : Boolean = false ) {
			_keyLength = keyLength;
			_autoCreate = autoCreate;
		}

		final public function getItem( k1 : Object, k2 : Object = null, k3 : Object = null ) : Object {
			_temp[ 0 ] = k1;
			_temp[ 1 ] = k2;
			_temp[ 2 ] = k3;
			return getItem2( _temp );
		}

		final public function getItem2( key : Vector.<Object> ) : Object {
			var curCache : OneKeyCache = _cache;
			for ( var i : int = 0; i < _keyLength - 1; i++ ) {
				var childCache : OneKeyCache = curCache.getItem( key[ i ] ) as OneKeyCache;
				if ( !childCache ) {
					if ( !_autoCreate ) {
						return null;
					}
					childCache = OneKeyCache.create();
					curCache.setItem( childCache, key[ i ] );
				}
				curCache = childCache;
			}
			var item : Object = curCache.getItem( key[ _keyLength - 1 ] );
			if ( !item && _autoCreate ) {
				item = createItem( key );
				curCache.setItem( item, key[ _keyLength - 1 ] );
			}
			return item;
		}


		final public function addItem( item : Object, k1 : Object, k2 : Object = null, k3 : Object = null ) : void {
			_temp[ 0 ] = k1;
			_temp[ 1 ] = k2;
			_temp[ 2 ] = k3;
			addItem2( item, _temp );
		}

		final public function addItem2( item : Object, key : Vector.<Object> ) : void {
			var curCache : OneKeyCache = _cache;
			for ( var i : int = 0; i < _keyLength - 1; i++ ) {
				var childCache : OneKeyCache = curCache.getItem( key[ i ] ) as OneKeyCache;
				if ( !childCache ) {
					childCache = OneKeyCache.create();
					curCache.setItem( childCache, key[ i ] );
				}
				curCache = childCache;
			}
			curCache.setItem( item, key[ _keyLength - 1 ] );
		}

		final public function disposeItems( k1 : Object, k2 : Object = null, k3 : Object = null ) : void {
			_temp[ 0 ] = k1;
			_temp[ 1 ] = k2;
			_temp[ 2 ] = k3;
			disposeItems2( _temp );
		}

		private function disposeCache( curCache : OneKeyCache, key : Vector.<Object>, i : int ) : void {
			if ( !curCache ) {
				return;
			}
			var keyPart : Object = key[ i ];
			if ( i === _keyLength - 1 ) {
				if ( keyPart ) {
					if ( !curCache.getItem( key[i] ) ) {
						return;
					}
					disposeItem( curCache.getItem( key[i] ) );
					curCache.delItem( key[i] );
				} else {
					for each ( var item : Object in curCache.dict ) {
						disposeItem( item );
					}
					curCache.dispose();
				}
			} else {
				if ( keyPart ) {
					disposeCache( curCache.getItem( key[i] ) as OneKeyCache, key, i + 1 );
				} else {
					for each ( var childCache : OneKeyCache in curCache.dict ) {
						disposeCache( childCache, key, i + 1 );
					}
				}
			}
		}

		final public function disposeItems2( key : Vector.<Object> ) : void {
			disposeCache( _cache, key, 0 );
		}

		protected function createItem( key : Vector.<Object> ) : Object {
			return null;
		}

		protected function disposeItem( item : Object ) : void {

		}


	}

}

import flash.utils.Dictionary;

class OneKeyCache {

	static private var _pool : Vector.<OneKeyCache> = new Vector.<OneKeyCache>();

	static public function create() : OneKeyCache {
		if ( _pool.length ) {
			return _pool.pop();
		}
		return new OneKeyCache();
	}

	public var dict : Dictionary;

	public function OneKeyCache() {
		dict = new Dictionary();
	}

	public function getItem( key : Object ) : Object {
		return dict[ key ]
	}

	public function setItem( item : Object, key : Object ) : void {
		dict[ key ] = item;
	}

	public function delItem( key : Object ) : void {
		delete dict[ key ];
	}

	public function dispose() : void {
		for ( var k : Object in dict ) {
			delete dict[ k ];
		}
	}

}
