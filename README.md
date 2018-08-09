# EasyPeasy 2.0
Weak and duplicated passwords scanner.

# Overview
EasyPeasy is a tool that scans for weak passwords by comparing the domain accounts' passwords to a database of common passwords.
The tool also scans for accounts with identical passwords.

The tool runs on PowerShell version 4 and up and use Invoke-DCSync to extract passwords hashes from Active Directory.

Clear text passwords or password hashes are not revealed to the user or saved on disk.

# Usage:
The tool runs on PowerShell version 4 and up and must be executed with domain administrator's privileges.

Option 1 - from the command line:
- Open Windows PowerShell (PowerShell - with ExecutionPolicy ByPass, in order to do that, type  this command in PowerShell command line: "Set-ExecutionPolicy -ExecutionPolicy Bypass"), and change directory to the one where the files are downloaded (for example: cd C:\Users\administrator\Downloads).
- Type ".\ep.ps1" and press Enter.

Option 2 - from the directory:
- Right click on ep.ps1, and click on 'Run with PowerShell' (PowerShell - with ExecutionPolicy ByPass).

# Sample output:

 Getting Hashes from Active Directory...
 
Comparing hashes...

Checking if the hashes are 'strong'...

We found 4 Users with the SAME password

We found 3 Users with WEAK password

=============================================================

Writing the results to file...

done! check out the results in the path: C:\Users\ADMINI~1\AppData\Local\Temp\easypeasy\EPoutput.txt

Press Enter to exit...
# Sample scan result:
 If the there are no weak passwords or password duplicates in the domain the file (EPoutput.txt) will be empty.
 
Sample scan result file:

=============================================================


 The users below have the SAME password:
 
SuperMario

Miki Mouse

=============================================================

The user below has a WEAK password:

cinderella

=============================================================

The users below have the SAME password and a WEAK one:

domainuser

cat

=============================================================

 # References:
 The tool uses Invoke-DCSync by @monoxgas (Nick Landers), with a little change.
 
 The tools was created by Cyberark Labs security princess - @sschwartzer. Thank you.
 
