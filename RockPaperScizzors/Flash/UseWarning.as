package  {
	import flash.events.Event;
	import flash.display.MovieClip;
	public class UseWarning extends MovieClip {

		public function UseWarning() {
			// constructor code
			alpha = 0;
			addEventListener(Event.ENTER_FRAME, eFrame);
			addEventListener(Event.ENTER_FRAME, clean);
		}
		private function eFrame(event:Event):void{
			if(alpha > 0){
				alpha -= 0.05;
			}
		}
		private function clean(event:Event):void{
			removeEventListener(Event.ENTER_FRAME, clean);
		}
	}
	
}
