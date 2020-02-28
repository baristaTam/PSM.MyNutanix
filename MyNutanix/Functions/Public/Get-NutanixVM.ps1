<#
.Synopsis
   Returns a specific VM object from the Nutanix envrionment
.DESCRIPTION
   Returns a specific VM object from the Nutanix envrionment
.PARAMETER Identity
    Hostname or UUID of the VM object you want returned. Accepts wildcards but is case sensitive.
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.EXAMPLE
   Get-NutanixVM -Identity "WindowsTemplate-Server2019"
.EXAMPLE
    Get-NutanixVM -Identity *test*
.EXAMPLE
   Get-NutanixVM -Identity "03937a81-2ac6-4b0c-a9c7-17e31bb3520b"
#>
function Get-NutanixVM
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
        #Check if ID was provided as Name or UUID
        If($Identity -like "*-*-*-*-*"){
            $UUID = $True
        }
        Else{
            $UUID = $False
        }    
        
        $Splat = @{
            URI = [string]::Empty
            Headers = Get-NutanixRestHeader -Credential $Credential
            SkipCertificateCheck = $True
            Method = [string]::Empty
        }

        #Do the VM Lookup with UUID
        if($UUID){
            $Splat['URI'] = "$($Script:Settings.Hostname)/api/nutanix/v3/vms/$($Identity)"
            $Splat['Method'] = "GET"
            Write-Verbose -Message "Looking up VM with UUID $($Identity)"
            Invoke-RestMethod @Splat
        }
        else{
            #Change wildcard char * to match regex expectations .*
            $Identity = $Identity.replace("*",".*")
            #Do the VM Lookup with Name, this is CASE SENSITIVE    
            $Body = @{
                "offset"= 0
                "length"= 999 
                "filter" = "vm_name==$($identity)"
            } | ConvertTo-Json

            $Splat['URI'] = "$($Script:Settings.Hostname)/api/nutanix/v3/vms/list"
            $Splat['Method'] = "POST"
            $Splat.add('Body', $Body)
            (Invoke-RestMethod @Splat).entities 
            
        }      
    }
    End
    {
    }
}