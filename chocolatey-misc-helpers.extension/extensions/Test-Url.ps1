$ErrorActionPreference = 'Stop'
# chocolatey-misc-helpers.extension v0.0.4 (08-24-2020) by Bill Curran - public domain
# Test a download URL and return true if it's valid or false if it's not.
# Use before Install-ChocolateyPackage so that you can switch to an alternative URL.
# Recommended implementation: define $UrlAlt and $Url64Alt in your nuspec similar to $Url and $Url64.
# Add the following 2 lines to your chocolateyInstall script to check and use the alternate URL when the primary is bad:
# if (Test-URL "$Url") {} else {if (Test-URL "$UrlAlt"){$Url=$UrlAlt}}
# if (Test-URL "$Url64") {} else {if (Test-URL "$Url64Alt"){$Url64=$Url64Alt}}
# Thanks to https://stackoverflow.com/questions/23760070/the-remote-server-returned-an-error-401-unauthorized

function Test-URL([string]$Url){
if (($Url -match "http://") -or ($Url -match "https://")){
     $httpResponse = $null
     $HttpRequest = [System.Net.WebRequest]::Create($Url)
     try{
         $httpResponse = $HttpRequest.GetResponse()
         $httpStatus = [int]$httpResponse.StatusCode
         if ($httpStatus -eq 200) { 
           return $true
         } else {
           return $true
         }
         $httpResponse.Close()
        } catch {
          $httpStatus = [regex]::Matches($_.exception.message, "(?<=\()[\d]{3}").Value
          return $false
        }
   }
}
