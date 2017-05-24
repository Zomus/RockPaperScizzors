package  {
	import flash.events.Event;
	import flash.display.MovieClip;
	public class Darkener extends MovieClip {
		private var jumpFrame:int;
		private var flashing:Boolean;
		private var targetDark:Number;
		
		public function Darkener() {
			// constructor code
			visible = false;
			//begins invisible
			mouseEnabled = false;
			//able to click through object
		}
		public function flashDark(jump:* = 0):void{
			//jumpframe refers to the frame to which this jumps to, if required
			if(!flashing){
				visible = true;
				alpha = 0;
				
				if(jumpFrame != 0){
					jumpFrame = jump;
				}
				
				flashing = true;
				//cannot call another flashDark if the screen is already flashing
				
				addEventListener(Event.ENTER_FRAME, flashDarkEvent);
			}else{
				trace("Flash failed");
			}
		}
		private function flashDarkEvent(event:Event):void{
			var darker:Boolean = true;
			//is the screen darkening
			
			if(darker){
				alpha += 0.1;
			}
			if(alpha >= 1){
				darker = false;
				gotoAndStop(jumpFrame);
			}
			if(darker == false && alpha <= 0){
				removeEventListener(Event.ENTER_FRAME, flashDarkEvent);
				flashing = false;
			}
		}
		public function setDarken(newAlpha:Number):void{
			if(!flashing){
				visible = true;
				targetDark = newAlpha;
				addEventListener(Event.ENTER_FRAME, fade);
			}else{
				trace("Fade failed");
			}
			
		}
		private function fade(event:Event):void{
			alpha += (targetDark - alpha)/10;
			if(Math.abs(targetDark - alpha) < 0.01){
				if(targetDark == 0){
					visible = false;
				}
				flashing = false;
				removeEventListener(Event.ENTER_FRAME, fade);
			}
		}
	}
	
}
