#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

NUMBER=$(( RANDOM % 1000 + 1 ))
#echo $NUMBER

NUMBER_OF_GUESSES=0

USERNAME() {
    echo "Enter your username:"
    read USERNAME
    echo $($PSQL "insert into users(username) values('$USERNAME') on conflict(username) do update set username = users.username returning user_id, games_played, best_score") | while read USER_ID BAR GAMES_PLAYED BAR BEST_SCORE_PLUS_JUNK
    do
      BEST_SCORE=$(echo $BEST_SCORE_PLUS_JUNK | sed -E 's/^([0-9]+).*/\1/')
      if [[ $GAMES_PLAYED -eq 0 ]]
      then
        echo -e "\nWelcome, $USERNAME! It looks like this is your first time here." 
      else
        echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
      fi
    done
}

GAME() {
    if [[ $1 ]]
    then
      echo -e "\n$1"
    else
      echo -e "\nGuess the secret number between 1 and 1000:"
    fi
    read GUESS
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      
      GAME "That is not an integer, guess again:"
    elif [[ $GUESS -lt $NUMBER ]]
    then
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
      GAME "It's higher than that, guess again:" 
    elif [[ $GUESS -gt $NUMBER ]]
    then
    NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
      GAME "It's lower than that, guess again:"
    elif [[ $GUESS -eq $NUMBER ]]
    then
      NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
      INSERT_SCORE=$($PSQL "UPDATE users SET best_score = CASE WHEN (best_score IS NULL OR best_score < $NUMBER_OF_GUESSES) THEN $NUMBER_OF_GUESSES ELSE best_score END, games_played = games_played + 1 WHERE username = '$USERNAME' RETURNING games_played")
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"    
    fi 
}

USERNAME
GAME
