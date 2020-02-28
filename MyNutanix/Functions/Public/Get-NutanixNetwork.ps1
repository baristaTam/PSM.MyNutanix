<#
.Synopsis
   Returns a specific subnet object from the Nutanix envrionment
.DESCRIPTION
   Returns a specific subnet object from the Nutanix envrionment
.PARAMETER Identity
    Name or UUID of the subnet object you want returned. Accepts wildcards  
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.EXAMPLE
   Get-NutanixNetwork -Identity "Inside_10.10.10.0/24"
.EXAMPLE
    Get-NutanixNetwork -Identity *
.EXAMPLE
   Get-NutanixNetwork -Identity "dc8ae36f-c848-42a9-b3a7-2a2b75572fc4"
#>
function Get-NutanixNetwork
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

        if($UUID){
            $Splat['URI'] = "$($Script:Settings.Hostname)/api/nutanix/v3/subnets/$($Identity)"
            $Splat['Method'] = "GET"
            Invoke-RestMethod @Splat
        }
        else{
            #Change wildcard char * to match regex expectations .*
            $Identity = $Identity.replace("*",".*")

            $Body = @{
                "offset"= 0
                "length"= 999 
                "filter" = "name==$identity"
            } | ConvertTo-Json

            $Splat['URI'] = "$($Script:Settings.Hostname)/api/nutanix/v3/subnets/list"
            $Splat['Method'] = "POST"
            $Splat.add('Body', $Body)
            (Invoke-RestMethod @Splat).entities 
            
        }      
        
    }
    End
    {
    }
}