<#
.Synopsis
    Sets the NIC on a specific VM object from the Nutanix environment
.DESCRIPTION
    Sets the NIC on a specific VM object from the Nutanix environment
.PARAMETER VMIdentity
    UUID or Name of the VM you want to set the NIC on. Accepts wildcards but it must only return a single VM or an error will be thrown. 
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.PARAMETER IsConnected
    Optional boolean value to set whether or not the NIC is connected or not 
.PARAMETER NetworkIdentity
    UUID or Name of the Network you want to set the VM's NIC to
.PARAMETER NicUUID
    Optionally specify the UUID of the NIC you want to change settings on if there is more than one NIC
.EXAMPLE
    Set-NutanixVMnetwork -VMIdentity "WindowsTemplate-Server2019" -NetworkIdentity "Inside_10.10.10.0/24"
 
#>
function Set-NutanixVMnetwork
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
  
        [Parameter(Mandatory=$true,Position=0)]
        [Alias("VMName","VMUUID")]
        [String]$VMIdentity,

        [Parameter(Mandatory=$true,Position=1)]
        [System.Management.Automation.PSCredential]$Credential,

        [bool]$IsConnected,

        [Parameter(Mandatory=$true)]
        [Alias("NetworkName","NetworkUUID")]
        [String]$NetworkIdentity,

        [String]$NicUUID

    )

    Begin
    {
    }
    Process
    {
            
        $VM = Get-NutanixVM -Identity $VMIdentity -Credential $Credential
        If(($VM | Measure-Object).count -gt 1)
        {
            Throw "More than one VM found matching identity $($VMIdentity)"
        }

        If( (($VM.spec.resources.nic_list | Measure-Object).count -gt 1) -and !$NicUUID )
        {
            Throw "More than one nic found on $($VM.Name). Need to specify with NicUUID parameter."
        }
        Else
        {
            $NicUUID = $VM.spec.resources.nic_list[0].uuid
        }

        $Network = Get-NutanixNetwork -Identity $NetworkIdentity -Credential $Credential

        $VM.spec.resources.nic_list | Where-Object -FilterScript {$_.UUID -eq $NicUUID} | ForEach-Object -Process {
            $_.subnet_reference.kind = "subnet"
            $_.subnet_reference.Name = $Network.spec.Name
            $_.subnet_reference.uuid = $Network.metadata.uuid

            If($PSBoundParameters.Keys["IsConnected"])
            {
                $_.is_connected = $IsConnected
            }
        }

        $Body = $VM | Select-Object -property Spec,metadata
               
        $Splat = @{
            URI = "$($Script:Settings.Hostname)/api/nutanix/v3/vms/$($VM.metadata.uuid)"
            Headers = Get-NutanixRestHeader -Credential $Credential
            SkipCertificateCheck = $True
            Method = "PUT"
            Body = $Body | ConvertTo-Json -Depth 10                                                   
        }

        Invoke-RestMethod @Splat
        
    }
    End
    {
    }
}