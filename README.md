# ImportFromURL

This function, when added to a powershell script, imports a powershell module from a URL without downloading it to the machine.

This function allows for a module or script to be imnported into the current PowerShell scope without storing it on the local computer.
This script is based on original by Alec McCutcheon : https://github.com/AlecMcCutcheon/ImportFromURL

You can import this function to your scripts using the following one-line command:

```
Import-Module ([System.Reflection.Assembly]::Load((Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/alexisspencer/importFromURL/main/importfromURL.psm1").content))
```