<#
.Synopsis
   Return a Nutanix task object using the UUID of the task
.DESCRIPTION
   Return a Nutanix task object using the UUID of the task
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.PARAMETER UUID
    UUID of the task you want returned
.EXAMPLE
   Get-NutanixTask -UUID "938082bd-0cbf-4e23-8045-df291b9dad0b"
#>
function Get-NutanixTask
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Mandatory=$true,Position=1)]
        [String]$UUID
    )

    Begin
    {
    }
    Process
    {
        $TaskSplat = @{
            URI = "$($Script:Settings.Hostname)/api/nutanix/v3/tasks/$($UUID)"
            Headers = Get-NutanixRestHeader -Credential $Credential
            SkipCertificateCheck = $True
            Method = "GET"
        }
        Invoke-RestMethod @TaskSplat

    }
    End
    {
    }
}