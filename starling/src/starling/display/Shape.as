package starling.display {

	public class Shape extends DisplayObjectContainer {
		private var _graphics : Graphics;

		public function Shape() {
			_graphics = new Graphics( this );
		}

		public function get graphics() : Graphics {
			return _graphics;
		}
	}
}