<#
.Synopsis
   Returns the IP of a specific VM in the Nutanix envrionment
.DESCRIPTION
   Returns the IP of a specific VM in the Nutanix envrionment
.PARAMETER Identity
    Hostname or UUID of the VM you want the IP of. Accepts wildcards but is case sensitive.
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.EXAMPLE
   Get-NutanixVMIP -Identity "WindowsTemplate-Server2019"
.EXAMPLE
    Get-NutanixVMIP -Identity *test*
.EXAMPLE
   Get-NutanixVMIP -Identity "03937a81-2ac6-4b0c-a9c7-17e31bb3520b"
#>
function Get-NutanixVMIP
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
  
        [Parameter(Mandatory=$true,Position=0)]
        [Alias("Name","UUID")]
        [String]$Identity,
        
        [Parameter(Mandatory=$true,Position=1)]
        [System.Management.Automation.PSCredential]$Credential

    )

    Begin
    {
    }
    Process
    {       
        #create an object with VMName, NicUUID and IPs for each NIC per VM queried
        Get-NutanixVM -Identity $Identity -Credential $Credential | ForEach-Object -Process {
            $VM = $_
            $_.status.resources.nic_list | ForEach-Object -Process {
                [pscustomobject]@{
                    VMName = $VM.status.name
                    NicUUID = $_.UUID
                    IPs = $_.ip_endpoint_list.ip  
                }
            }
        }
    }
    End
    {
    }
}