package  {
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.utils.Timer;

	public class ClickButton extends MovieClip{
		
		private var targetSize:int;
		
		public function ClickButton() {
			targetSize = width;
			//original target is what it is originally
			
			//goes to its respective frame
			if(name == "playerChoice" || name == "opponentChoice"){
				gotoAndStop("Question");
				buttonMode = false;
				//not clickable
			}else{
				if(name == "rockButton"){
					gotoAndStop("Rock");
				}
				else if(name == "paperButton"){
					gotoAndStop("Paper");
				}
				else if(name == "scizzorsButton"){
					gotoAndStop("Scizzors");
				}
				
				addEventListener(MouseEvent.MOUSE_OVER, enlargeTargetSize);
				addEventListener(MouseEvent.MOUSE_OUT, resetTargetSize);
				addEventListener(Event.ENTER_FRAME, zoomTargetSize);
			}
			
		}
		
		private function enlargeTargetSize(event:Event):void{
			targetSize = 150;
		}
		
		private function resetTargetSize(event:Event):void{
			targetSize = 125;
		}
		
		private function zoomTargetSize(event:Event):void{
			width += (targetSize - width)/4;
			height += (targetSize - height)/4;
		}
		public function popAns():void{
			if(width != 50){
				width = 50;
				height = 50;
				//resize if proportions are incorrect
			}
			addEventListener(Event.ENTER_FRAME, popHelper);
			var popSpeed:int = 10;
			var popAccel:int = -2;
			function popHelper(event:Event):void{
				width += popSpeed;
				height += popSpeed;
				popSpeed += popAccel;
				if(width < 50){
					width = 50;
					height = 50;
					removeEventListener(Event.ENTER_FRAME, popHelper);
				}
			}
		}
	}
	
}
