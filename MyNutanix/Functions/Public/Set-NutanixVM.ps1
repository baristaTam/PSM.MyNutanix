<#
.Synopsis
   Sets options on a specific VM object from the Nutanix environment
.DESCRIPTION
   Sets options on a specific VM object from the Nutanix environment
.PARAMETER Identity
    Hostname or UUID of the VM object you want modified
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.PARAMETER NewName
    Optionally sets a new name of the VM
.PARAMETER PowerState
    Optionally set the power state of the VM to ON or OFF
.PARAMETER Memory
    Optionally set the memory of the VM. Must be in increments of 1024
.PARAMETER Description
    Optionally set the description of the VM. 
.PARAMETER Category
    Optionally set the category of the VM. Must be a "Name,Value" pair. This is primarily used for DSC tagging.     
.EXAMPLE
   Set-NutanixVM -Identity 6cf806cc-7a83-4d44-bef0-7580c6de6f0b -Memory 8192 -Category "Environment,Dev"
.EXAMPLE
   Set-NutanixVM -Identity Test_VM -NewName Production_VM -PowerState ON -Description "Does Production Things"
#>
function Set-NutanixVM
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
        [System.Management.Automation.PSCredential]$Credential,

        [Parameter(Position=2)]
        [string]$NewName,

        [Alias("memory_size_mib")]
        #Only allows memory in 1gb incriments
        [ValidateScript({ $_ % 1024 -eq 0 })]
        [Int]$Memory,

        [Alias("power_state")]
        [ValidateSet('ON','OFF')]
        [String]$PowerState,

        [String]$Description,

        [Array]$Category
    )

    Begin
    {
    }
    Process
    {
            
        $VM = Get-NutanixVM -Identity $Identity -Credential $Credential

        $Body = $VM | Select-Object -property Spec,metadata
        
        #Set the new VM name if specified
        If($NewName)
        {
            $Body.Spec.Name = $NewName
        }

        If($Description)
        {
            $Body.spec.description = $Description            
        }

        If($Category)
        {
            $Category = $Category.Split(",")
            $Body.metadata.categories | Add-Member -NotePropertyName $Category[0] -NotePropertyValue $Category[1]         
        }

        #Set all params, besides the NonVMKeys listed here, to their respective attribute in the payload
        [String[]]$NonVMKeys = ('Identity','NewName','Credential', 'Description', 'Category')
        $PSBoundParameters.Keys | Where-Object -FilterScript {$_ -notin $NonVMKeys} | ForEach-Object -Process {
            [String]$APIName = $MyInvocation.MyCommand.Parameters[$_].Aliases[0]
            $Body.Spec.resources.$APIName = $PSBoundParameters[$_]
        }

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