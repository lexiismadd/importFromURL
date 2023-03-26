# ImportFromURL

This function, when added to a powershell script, imports a powershell module from a URL without downloading it to the machine.

This function allows for a module or script to be imnported into the current PowerShell scope without storing it on the local computer.
This script is based on original by Alec McCutcheon : https://github.com/AlecMcCutcheon/ImportFromURL
Modifications from Alec's original code include the addition of credentials and auto-detecting whether the code is a script, module, or DLL based on the URL that is passed to the function.

You can import this function to your scripts using the following one-line command. The function will only remain on the machine as long as the session is active.

```
New-Module -Name "ImportFromURL" -ScriptBlock ([Scriptblock]::Create((Invoke-WebRequest -Uri "https://raw.githubusercontent.com/alexisspencer/importFromURL/main/importfromURL.psm1" -UseBasicParsing).Content)) | Import-Module
```

Obviously, you can also use this one liner for your own script importing without using this module.  
This module in this repo simply adds credentials, autodetection for file types, and extra errorchecking and verbosity for your sanity.


## Function usage:
```
Import-FromURL -URL <URL> [-Credential <credentials>] [-DLL] [-PS1] [-PSM1]
```

**-URL** *\<required\>* : This is the full URL of the PowerShell code or DLL module you wish to import. Make sure to encode the URL correctly (ie, spaces become %20 etc).

**-Credential** *\<optional\>* : This is a [PSCredential](https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/add-credentials-to-powershell-functions?view=powershell-5.1) object required to authenticate for downloading/accessing the code/DLL.

**-DLL** *\<optional\>* : Specifies the remote file is to be treated as a DLL file

**-PS1** *\<optional\>* : Specifies the remote file is to be treated as a PowerShell script

**-PSM1** *\<optional\>* : Specifies the remote file is to be treated as a PowerShell Module

