<#
.Synopsis
   Clones a specific VM in the Nutanix envrionment and returns the Nutanix task object for this operation
.DESCRIPTION
    Clones a specific VM in the Nutanix envrionment and returns the Nutanix task object for this operation
.PARAMETER Identity
    Hostname or UUID of the VM object you want cloned  
.PARAMETER Credential
    Credentials used to authenticate to the Nutanix environment
.PARAMETER NoWait
    Returns the task object before the task has succeeded, otherwise, this function does not return the task object until the task has succeeded 
.PARAMETER MaxWaitTime
    Number of seconds to wait for the cloning task to succeed before throwing an exception. Default is 600 seconds (10 minutes) 
.EXAMPLE
   New-NutanixVMClone -Identity "WindowsTemplate-Server2019" -Nowait
.EXAMPLE
   New-NutanixVMClone -Identity "03937a81-2ac6-4b0c-a9c7-17e31bb3520b" -Maxwait 60
#>
function New-NutanixVMClone
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
        [switch]$NoWait,
                
        [Parameter(Position=3)]
        [int]$MaxWait  = 600
        

    )

    Begin
    {
    }
    Process
    {
           
        $VM = Get-NutanixVM -Identity $Identity -Credential $Credential
       
        $Splat = @{
            URI = "$($Script:Settings.Hostname)/api/nutanix/v3/vms/$($VM.metadata.uuid)/clone"
            Headers = Get-NutanixRestHeader -Credential $Credential
            SkipCertificateCheck = $True
            Method = "POST"
            Body = @{} | ConvertTo-Json
        }
        
        $taskuuid = Invoke-RestMethod @Splat
        $Task = Get-NutanixTask -UUID $taskuuid.task_uuid -Credential $Credential

        If(-not $NoWait)
        {
            Write-Verbose -Message "Waiting for task to finish..."
            [int]$Waited = 0
            do
            {
                If($Waited -ge $MaxWait)
                {
                    throw "Wait for task '$($taskuuid.task_uuid)' exceeded max wait time of $($MaxWait) seconds."
                }
               
                $Task = Get-NutanixTask -UUID $taskuuid.task_uuid -Credential $Credential
                Start-Sleep -Seconds 5
                $Waited += 5
                Write-Verbose -Message "Waiting for task to finish..."
            }
            while ( $Task.status -ne "SUCCEEDED" )
        }

        $Task
        

        
    }
    End
    {
    }
}