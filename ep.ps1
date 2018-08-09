$dir = "$env:temp\easypeasy"

if(!(Test-Path -Path $dir )){
    mkdir $env:temp\easypeasy
}

$loc = Get-Location
$weakPass ="$loc\commonNTLMhashes.txt"


$ErrorActionPreference = 'silentlycontinue'
Import-Module .\Invoke-DCSync.ps1
Write-Host "Getting Hashes from Active Directory..."
Invoke-DCSync -AllData | Out-File -filepath $env:temp\easypeasy\dcsyncData.txt

$assemblies=(
    "System",
    "System.Core",
    "System.IO",
    "System.Text.RegularExpressions"
)
$source = @"
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

namespace classWay
{
    public class passwordDuplicates
    {
        string hash;
        string username;
        Dictionary<string, List<string>> usernamesAndPasswords = new Dictionary<string, List<string>>();
        string newFilePath = Path.GetTempPath() + "\\" + @"easypeasy\EPoutput.txt";
        public void fillDictionary(string hash, string username)
        {
            this.hash = hash;
            this.username = username;
            if (usernamesAndPasswords.ContainsKey(hash))
            {
                usernamesAndPasswords[hash].Add(username);
            }
            else
            {
                usernamesAndPasswords.Add(hash, new List<string>() { username });
            }
        }
        public void printAllDetail()
        {
            int UsersWithSamePass = 0;
            int UsersWithWeakPass = 0;
            Console.WriteLine("Checking if the hashes are 'strong'...");
            
            string WeakPassPath = @"$weakPass";
            using (StreamWriter sw = File.CreateText(newFilePath))
            {
                foreach (var contents in usernamesAndPasswords.Keys)
                {
                    int members = usernamesAndPasswords[contents].Count;
                    if (members >= 2)
                    {
                        if (File.ReadAllText(WeakPassPath).Contains(contents))
                        {
                            sw.WriteLine("The users below have the SAME password and a WEAK one:");
                            foreach (var listMember in usernamesAndPasswords[contents])
                            {
                                sw.WriteLine(listMember);
                                UsersWithSamePass++;
                                UsersWithWeakPass++;
                            }
                            sw.WriteLine("=============================================================");

                        }
                        else
                        {
                            sw.WriteLine("The users below have the SAME password:");
                            foreach (var listMember in usernamesAndPasswords[contents])
                            {
                                sw.WriteLine(listMember);
                                UsersWithSamePass++;
                            }
                            sw.WriteLine("=============================================================");
                        }
                    }
                    else
                    {
                        if (File.ReadAllText(WeakPassPath).Contains(contents))
                        {
                            sw.WriteLine("The user below has a WEAK password:");
                            foreach (var listMember in usernamesAndPasswords[contents])
                            {
                                sw.WriteLine(listMember);
                                UsersWithWeakPass++;
                            }
                            sw.WriteLine("=============================================================");
                        }
                    }
                }
            }

            Console.WriteLine("\nWe found "+UsersWithSamePass+" Users with the SAME password");
            Console.WriteLine("We found " + UsersWithWeakPass + " Users with WEAK password");
            Console.WriteLine("=============================================================\nWriting the results to file...");
        }
    }
    public class Program
    {
        public static void Main()
        {
            string filePath = Path.GetTempPath() + "\\" + @"easypeasy\dcsyncData.txt";
            string content = File.ReadAllText(filePath);
            content = content.Replace("\r", "");
            content.Replace("\t", "");
            string[] SamAccounts = content.Split(new string[] { "** SAM ACCOUNT **" }, StringSplitOptions.None);
            string patternHash = "Hash NTLM: [a-z[0-9]{32}";
            Regex rgxHash = new Regex(patternHash);
            string patternUsername = "SAM Username         : .*";
            Regex rgxUsername = new Regex(patternUsername);
            passwordDuplicates anInstanceofMyClass = new passwordDuplicates();
            Console.WriteLine("Comparing hashes...");
            foreach (string t in SamAccounts)
            {
                Match matchHash = Regex.Match(t, patternHash);

                if (matchHash.Success)
                {
                    Match matchUsername = Regex.Match(t, patternUsername);
                    if (matchUsername.Success)
                    {
                        anInstanceofMyClass.fillDictionary(matchHash.Value.Substring(11, 32), matchUsername.Value.Substring(23));
                    }
                }
            }
            anInstanceofMyClass.printAllDetail();
        }
    }
}
"@

Add-Type -ReferencedAssemblies $assemblies -TypeDefinition $source -Language CSharp
[classWay.Program]::Main()
Remove-Item –path $env:temp\easypeasy\dcsyncData.txt
Write-Host "done! check out the results in the path: $dir\EPoutput.txt"
Read-Host -Prompt "Press Enter to exit"