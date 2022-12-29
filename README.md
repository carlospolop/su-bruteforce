# su-bruteforce

This tool **bruteforces a selected user** using `su` and as passwords: **null password, username, reverse username and a wordlist (top12000.txt).**

You can specify a username using `-u <username>` and a wordlist via `-w <wordlist>`.

By **default** the BF default speed is using 100 su processes at the same time (each su try last 0.7s and a new su try in 0.007s). It **needs 143s to complete**.

You can configure these times using `-t` (timeout `su` process) and `-s` (sleep between 2 `su` processes). 

**Fastest recommendation**: `-t 0.5` (minimun acceptable) and `-s 0.003` ~ **108s to complete.**
```
./suBF.sh -u <USERNAME> [-w top12000.txt]  [-t 0.7] [-s 0.007]
```

In addition to files, you can **pipe the output from other commands** to provide the wordlist, examples:

```bash
curl -s http://10.10.10.10/wordlist.txt | ./suBF.sh -u <USERNAME> -w -
seq 0 1000 | ./suBF.sh -u <USERNAME> -w -
``` 
