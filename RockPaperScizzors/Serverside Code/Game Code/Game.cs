using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using PlayerIO.GameLibrary;
using System.Drawing;

namespace RockPaperScizzors
{
    //Player class. each player that join the game will have these attributes.
    public class Player : BasePlayer
    {
        public string Name;
    }
    public class Match
    {
        public List<Match> parentMatchList;
        //reference to the match list that stores this match (to be removed from when the match is over)

        public Player player1, player2;
        //players 1 and 2

        public int response1 = 0;
        public int response2 = 0;
        /*current responses of the 2 players
         * 0 = no response yet
         * 1 = rock
         * 2 = paper
         * 3 = scizzors
         * 4 = machine is ignored (time is up, no answer submitted)
         */

        //Constructor
        public Match(List<Match> matchList, Player p1, Player p2)
        {
            parentMatchList = matchList;
            player1 = p1;
            player2 = p2;
        }

        public void inputResponse(bool playerIs1, int response)
        {
            if (playerIs1)
            {
                if(response1 == 0) //response can only be inputted if no response has EVER been recorded
                {
                    response1 = response;
                }
            }
            else
            {
                if (response2 == 0)
                {
                    response2 = response;
                }
            }
            if(response1 != 0 && response2 != 0) //both players have submitted
            {
                if((response1 > 4 || response1 < 0) && (response2 > 4 || response2 < 0)) //Both cheated
                {
                    //disconnect both players
                    player1.Disconnect();
                    player2.Disconnect();
                }
                else if(response1 > 4 || response1 < 0) //player1 cheated
                {
                    player1.Disconnect();
                    player2.Send("ReceiveAns", 4);
                }
                else if (response2 > 4 || response2 < 0) //player2 cheated
                {
                    player1.Send("ReceiveAns", 4);
                    player2.Disconnect();
                }
                else //nobody cheated
                {
                    player1.Send("ReceiveAns", response2);
                    player2.Send("ReceiveAns", response1);
                    //send responses back to players
                }

                parentMatchList.Remove(this);
                //resolve match
            }
        }
    }

    [RoomType("RockPaperScizzors")]
    public class GameCode : Game<Player>
    {
        private int onlineUsers;
        //number of online users
        private List<Player> pending;
        //list of players that are waiting for a match
        private List<Match> activeMatches;
        //list of active matches that currently exist

        public override void GameStarted()
        {
            onlineUsers = 0;
            pending = new List<Player>();
            activeMatches = new List<Match>();
        }
        public override void UserJoined(Player player)
        {
            onlineUsers++;
            //add one to online users
        }
        public override void UserLeft(Player player)
        {
            onlineUsers--;
            //subtract one from online users

            //If user is waiting for match and disconnects...
            pending.Remove(player);
            //removes the player from the pending list if the player can be found on the list

            //If user is in a match and disconnects...
            foreach (Match match in activeMatches)
            {
                if (match.player1 == player) //if the player is a player1
                {
                    match.player2.Send("ReceiveAns", 0);
                    //receiving 0 means the player did not submit an answer --> left
                    match.parentMatchList.Remove(match);
                    //resolve the match
                }
                else if (match.player2 == player) //if the player is a player2
                {
                    match.player1.Send("ReceiveAns", 0);
                    match.parentMatchList.Remove(match);
                }
            }
        }
        public override void GotMessage(Player player, Message message)
        {
            if (message.Type == "Username") //user will either be pending for a match or matched after username is obtained from client
            {
                player.Name = message.GetString(0);
                if (pending.Count == 0) //there are no pending players
                {
                    pending.Add(player);
                    //add player to the list of pending players to be matched
                }
                else //otherwise, match the players
                {
                    beginMatch(player, pending[0]);
                    //begin a match with the two players
                    pending.RemoveAt(0);
                    //remove player from list
                }
            }

            if (message.Type == "Answer")
            {
                bool playerInMatch = false;
                //boolean to check if the player exists in any of the matches

                foreach(Match match in activeMatches)
                {
                    if(match.player1 == player) //if the player is a player1
                    {
                        match.inputResponse(true, message.GetInt(0));
                        //input response to the match
                        playerInMatch = true;
                    }
                    else if (match.player2 == player) //if the player is a player2
                    {
                        match.inputResponse(false, message.GetInt(0));
                        //input response to the match
                        playerInMatch = true;
                    }
                }

                if(!playerInMatch)
                { //if no matches are found with the player in it, disconnect the player
                    player.Send("Disconnect");
                }
                
            }
        }
        public void beginMatch(Player player1, Player player2)
        {
            player1.Send("OpponentFound", player2.Name); //sends that match is found along with opponent name
            player2.Send("OpponentFound", player1.Name);
            Match tempMatch = new Match(activeMatches, player1, player2);
            activeMatches.Add(tempMatch);

            ScheduleCallback(delegate
            {
                if(tempMatch != null) //if match still exists (after 12 seconds (longer than it should))
                {
                    //Inputs that nothing has been done for both players (recall answers cannot be overwritten)
                    tempMatch.inputResponse(true, 4);
                    tempMatch.inputResponse(false, 4);
                }
            }, 30000);
        }
    }
}
