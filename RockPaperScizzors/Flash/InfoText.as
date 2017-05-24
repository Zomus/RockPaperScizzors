package  {
	import flash.display.MovieClip;
	import flash.events.Event;

	public class InfoText extends MovieClip {

		public function InfoText() {
			stop();
			//stop infotext at stationary frame
			
			buttonMode = false;
			//make infotext non-interactable by mouse
		}
		public function bannerPrint(str:String):void{
			gotoAndPlay("Banner");
			movingText.txt_infoText.text = str;
		}
		public function stillPrint(str:String):void{
			gotoAndStop("Stationary");
			movingText.txt_infoText.text = str;
		}
	}
	
}
