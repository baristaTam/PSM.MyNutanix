<#
.Synopsis
   Generates a header with the provided credentials to authenticate the REST API call to the Nutanix envrionment
.DESCRIPTION
   Generates a header with the provided credentials to authenticate the REST API call to the Nutanix envrionment
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.EXAMPLE
   $Credential = Get-Credential

   $TaskSplat = @{
        URI = "https://myNutanixServer:9440/api/nutanix/v3/tasks/$uuid"
        Headers = Get-NutanixRestHeader -Credential $Credential
        Method = "GET"
    }
    $Task = Invoke-RestMethod @TaskSplat
#>
function Get-NutanixRestHeader
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [System.Management.Automation.PSCredential]$Credential
    )

    Begin
    {
    }
    Process
    {
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password)
        $credPair = "$($credential.UserName):$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR))"
        $Base64Credential = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))

        $Header = @{
            "Content-Type" = "application/json"
            "Authorization" = "Basic $($Base64Credential)"
        }
        $Header
    }
    End
    {
    }
}