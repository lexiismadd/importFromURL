# --------------------------------------------------------------------------------------------------
# This function allows for a module or script to be imnported into the current PowerShell scope 
# without storing it on the local computer
# Original script by Alec McCutcheon : https://github.com/AlecMcCutcheon/ImportFromURL
# --------------------------------------------------------------------------------------------------

# This imports a powershell module or script from a URL
function Import-FromURL {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true,ValueFromPipeLine = $true)]
        [string]$URL,
        [Parameter(Mandatory = $false,ValueFromPipeLine = $true)]
        [pscredential]$Credential,
        [Parameter(Mandatory = $false)]
        [switch]$DLL,
        [Parameter(Mandatory = $false)]
        [switch]$Ps1,
        [Parameter(Mandatory = $false)]
        [switch]$Psm1
    )

    process {
        if (($URL -as [System.URI]).IsAbsoluteUri -eq $False) {
            Write-Error "URL is Missing http:// or https://" -Category InvalidArgument
            $PScmdlet.ThrowTerminatingError()
        }
        if ($URL -match ".DLL" -or $DLL -eq $true) {
            try{
                Write-Verbose "Importing DLL" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
                Import-Module ([System.Reflection.Assembly]::Load((Invoke-WebRequest -UseBasicParsing -Uri $URL).content)) -ErrorAction SilentlyContinue > $null
            }catch{
                Write-Verbose "Import-Module Failed to Import DLL, Make sure the Url is a direct link to the file." -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
                Write-Error $_
            }
        } elseif ($URL -match ".psm1" -or $Psm1 -eq $true) {
            try{
                # Get module name without extension
                Write-Verbose "Importing PowerShell Module" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
                $ModuleFileNameComponents = (Split-Path $URL -Leaf).Split(".")
                $ModuleName = (Split-Path $URL -Leaf).Replace(".$($ModuleFileNameComponents[$ModuleFileNameComponents.count-1])","")
                if($Credential) {
					$ImportedCode = (Invoke-WebRequest -Uri $URL -UseBasicParsing -Credential $Credential).Content
				} else {
                    $ImportedCode = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content
                }
                New-Module -Name "$($ModuleName)" -ScriptBlock ([Scriptblock]::Create($ImportedCode)) -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true) | Import-Module
                #New-Module -Name "$($ModuleName)" -ScriptBlock {$ImportedCode.Content} -ErrorAction SilentlyContinue > $null
            }catch{
                Write-Verbose "Import-Module Failed to Import Psm1 Module, Make sure the Url is a direct link to the raw code" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
                Write-Error $_
            }
        } elseif ($URL -match ".ps1" -or $Ps1 -eq $true) {
            try{
                Write-Verbose "Importing PowerShell script" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
                if($Credential) {
					$ImportedCode = (Invoke-WebRequest -Uri $URL -UseBasicParsing -Credential $Credential).Content
				} else {
                    $ImportedCode = (Invoke-WebRequest -Uri $URL -UseBasicParsing).Content
                }
                Invoke-Command -ScriptBlock ([Scriptblock]::Create($ImportedCode))
                Write-Verbose "Attempting to invoke the Ps1 script (There is no error handling for .Ps1 scripts)" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
                Write-Verbose "Windows Bug Tip: If a script prompts for UAC and then force closes the Session, Try running the session as admin" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
            } catch {
                Write-Verbose "Importing script failed, Make sure the Url is a direct link to the raw code" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
                Write-Error $_
            }
        } else {
            Write-Error "Could not detemine the type of code to import. The URL does not contain any of file extensions: .DLL, .PS1, or .PSM1, or URL is Invalid. Please add the -DLL, -Ps1 or -Psm1 parameter to let the function know what file type it is." -Category InvalidType
        }
    }
}

# --------------------------------------------------------------------------------------------------

