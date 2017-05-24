package  {
	import playerio.*;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import com.protobuf.Message;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class RockPaperScizzors extends MovieClip {
		
		public static var allPurposeTimer:Timer = new Timer(1000);
		//all purpose timer used for a lot of stuff
		
		public static var userName:String = "";
		public static var opponentName:String = "";
		
		public static var gameID:String = "rockpaperscizzors-koqhxljedu6bhmjclbqp5g";
		
		public function RockPaperScizzors() {
			// constructor code
			stop();
			
			btn_start.addEventListener(MouseEvent.CLICK, begin);
			//start searching for opponent after start button is clicked
		}
		
		private function begin(event:MouseEvent):void{
			var rex:RegExp = /[\s\r\n]+/gim;
			//whitespace trimmer
			
			var formattedUsername = (txt_username.text).replace(rex,'');
			
			if(formattedUsername != ""){
				userName = txt_username.text;
				
				btn_start.removeEventListener(MouseEvent.CLICK, begin);
				
				gotoAndStop("Searching");
				//go to searching for opponent frame
				
				//connect to the server
				PlayerIO.connect(
					stage,
					gameID,
					"public",
					"GuestUser", 
					"",		//change back to "" if it doesnt' work
					handleConnect,
					handleError
				);
			}else{ //Username not entered
				useWarning.alpha = 1;
			}
		}
		
		private function handleConnect(client:Client){
			trace("Successfully connected to server.");
			
			client.multiplayer.createJoinRoom(
				"test",
				"RockPaperScizzors",
				false,
				{},
				{},
				handleJoin,
				handleError
			);
		}
		
		private function handleJoin(connection:Connection){
			trace("Joined room. Searching for opponent");
			//No message has to be sent, as joining the room will run a serverside function "UserJoined" which will ready a pending request
			
			connection.send("Username", userName);
			
			var userAns:int = 4;
			//4 is no answer (question mark)
			
			connection.addMessageHandler("OpponentFound", function(m:Message, oppName:String){
				opponentName = oppName;
				
				gotoAndStop("MatchFound");
				//go to match found screen
				
				allPurposeTimer.reset();
				allPurposeTimer.start();
				allPurposeTimer.repeatCount = 5;
				allPurposeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startMatch);
				function startMatch(event:TimerEvent):void{
					gotoAndStop("Play");
					//go to play screen
					
					allPurposeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, startMatch);
					
					//SETUP SCREEN					
					
					//setup player names
					txt_player.text = userName;
					txt_opponent.text = opponentName;
					
					//play the buttons to their respective frames
					rockButton.gotoAndStop("Rock");
					paperButton.gotoAndStop("Paper");
					scizzorsButton.gotoAndStop("Scizzors");
					
					rockButton.addEventListener(MouseEvent.CLICK, rockSelect);
					paperButton.addEventListener(MouseEvent.CLICK, paperSelect);
					scizzorsButton.addEventListener(MouseEvent.CLICK, scizzorsSelect);					
					
					//darkener.visible = true;
					//darkener.alpha = 0.5;
					//darken the screen to half
					
					//print banner to indicate start of round
					bannerText.bannerPrint("Start!");
					
					//darkener.setDarken(0);
					//fade the screen
					
					allPurposeTimer.reset();
					allPurposeTimer.start();
					allPurposeTimer.repeatCount = 10;
					allPurposeTimer.addEventListener(TimerEvent.TIMER, displayCountdown);
					
					function displayCountdown(event:TimerEvent):void{
						txt_turnTimer.text = String(10 - allPurposeTimer.currentCount);
						//set timer time
					}
					
					allPurposeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sendAns);
					function sendAns(event:TimerEvent):void{
						
						rockButton.buttonMode = false;
						rockButton.removeEventListener(MouseEvent.CLICK, rockSelect);
						paperButton.buttonMode = false;	
						paperButton.removeEventListener(MouseEvent.CLICK, paperSelect);
						scizzorsButton.buttonMode = false;					
						scizzorsButton.removeEventListener(MouseEvent.CLICK, scizzorsSelect);
						//makes all buttons unclickable
						
						allPurposeTimer.removeEventListener(TimerEvent.TIMER, displayCountdown);
						//stops counting down
						allPurposeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, sendAns);
						//stops sending answers even though it is finished counting down
						
						connection.send("Answer", userAns);
					}
					
					function rockSelect(event:MouseEvent):void{
						userAns = 1;
						playerChoice.gotoAndStop(userAns);
						playerChoice.popAns();
					}
					
					function paperSelect(event:MouseEvent):void{
						userAns = 2;
						playerChoice.gotoAndStop(userAns);
						playerChoice.popAns();
					}
					
					function scizzorsSelect(event:MouseEvent):void{
						userAns = 3;
						playerChoice.gotoAndStop(userAns);
						playerChoice.popAns();
					}
					
				}
			});			
			
			connection.addMessageHandler("ReceiveAns", function(m:Message, oppAns:int){
				
				opponentChoice.gotoAndStop(oppAns);
				opponentChoice.popAns();
				
				if(userAns == 4 && oppAns == 4){
					bannerText.stillPrint("Game abandoned...");
				}
				
				else if(userAns == 4){
					bannerText.stillPrint("You left...Lose.");
				}
				
				else if(oppAns == 4){
					bannerText.stillPrint("Your opponent left...!");
				}
				
				else if(userAns == oppAns){
					bannerText.stillPrint("Tie");
				}
				
				else if(userAns == oppAns + 1 || (userAns == 1 && oppAns == 3)){
					bannerText.stillPrint("You WIN!");
				}
				else{
					bannerText.stillPrint("You LOSE.");
				}
				
				allPurposeTimer.reset();
				allPurposeTimer.start();
				allPurposeTimer.repeatCount = 5;
				allPurposeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, returnToMain);
				function returnToMain(event:TimerEvent):void{
					gotoAndStop("Title")
					btn_start.addEventListener(MouseEvent.CLICK, begin);
					//start searching for opponent after start button is clicked
					
					allPurposeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, returnToMain);
					
					connection.disconnect();
				}
				//disconnect and go back to title 5 seconds later
			});
			
			connection.addDisconnectHandler(function (){
				if(currentLabel == "Play"){
					gotoAndStop("Disconnect");
					
					allPurposeTimer.reset();
					allPurposeTimer.start();
					allPurposeTimer.repeatCount = 10;
					allPurposeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, goHome);
					
					function goHome(event:TimerEvent):void{
						gotoAndStop("Title");
						//set timer time
						allPurposeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, goHome);
					}
				}
			});
		}
		
		private function handleError(error:PlayerIOError){
			trace("Error");
		}
	}
	
}
