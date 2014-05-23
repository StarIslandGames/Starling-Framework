package com.sig.starling {

    import flash.text.TextField;
    import flash.text.TextFormat;

    import starling.text.TextField;

    public class ExtendedTextField extends starling.text.TextField {

        private var _multiline:Boolean = true;
        private var _wordWrap:Boolean = true;

        public function ExtendedTextField(width:int, height:int, text:String, fontName:String = "Verdana", fontSize:Number = 12, color:uint = 0x0, bold:Boolean = false) {
            super(width, height, text, fontName, fontSize, color, bold);
        }

        override protected function formatText(textField:flash.text.TextField, textFormat:TextFormat):void {
            super.formatText(textField, textFormat);
            textField.multiline = _multiline;
            textField.wordWrap = _wordWrap;
        }

        public function get multiline():Boolean {
            return _multiline;
        }

        /**
         * Set multiline for textfield (not applies to bitmap fonts)
         * @param value
         */
        public function set multiline(value:Boolean):void {
            if (_multiline != value) {
                _multiline = value;
                mRequiresRedraw = true;
            }
        }

        public function get wordWrap():Boolean {
            return _wordWrap;
        }

        public function set wordWrap(value:Boolean):void {
            if (_wordWrap != value) {
                _wordWrap = value;
                mRequiresRedraw = true;
            }
        }
    }
}
