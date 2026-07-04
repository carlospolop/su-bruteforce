# su-bruteforce

This tool **bruteforces a selected user** using `su` and as passwords: **null password, username, reverse username and a wordlist (top12000.txt).**

## Usage

### Single user mode
You can specify a username using `-u <username>` and a password wordlist via `-w <wordlist>`.
```bash
./suBF.sh -u <USERNAME> [-w top12000.txt] [-t 0.7] [-s 0.007]
```

### Multiple users mode
You can specify a username wordlist using `-U <userlist>` to try multiple users.
```bash
./suBF.sh -U <USERLIST> [-w top12000.txt] [-t 0.7] [-s 0.007]
```

### Auto-detect users mode
Use `-a` to auto-detect users with valid login shells from `/etc/passwd`.
```bash
./suBF.sh -a [-w top12000.txt] [-t 0.7] [-s 0.007]
```

## Options

| Option | Description |
|--------|-------------|
| `-u <username>` | Target a single username |
| `-U <userlist>` | File containing usernames to target (one per line) |
| `-a` | Auto-detect users with valid login shells from /etc/passwd |
| `-w <wordlist>` | Password wordlist (default: top12000.txt) |
| `-t <seconds>` | Timeout for each su process (default: 0.7) |
| `-s <seconds>` | Sleep between su processes (default: 0.007) |

## Performance

By **default** the BF default speed is using 100 su processes at the same time (each su try last 0.7s and a new su try in 0.007s). It **needs 143s to complete**.

You can configure these times using `-t` (timeout `su` process) and `-s` (sleep between 2 `su` processes).

**Fastest recommendation**: `-t 0.5` (minimun acceptable) and `-s 0.003` ~ **108s to complete.**

## Piping wordlists

In addition to files, you can **pipe the output from other commands** to provide the wordlist:

```bash
curl -s http://10.10.10.10/wordlist.txt | ./suBF.sh -u <USERNAME> -w -
seq 0 1000 | ./suBF.sh -u <USERNAME> -w -
``` 
