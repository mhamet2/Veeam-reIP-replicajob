# Powershell Script for Veeam. It is used to script the addition of adding in ReIP rules for replication jobs
# @davidstamen
# http://davidstamen.com

#Define Variables
param
(
    [Parameter(Mandatory=$False,
        HelpMessage='Path to CSV to Import')]
        [string[]]$csvlist
)

#Load Veeam Plugin
Add-PSSnapin -Name VeeamPSSnapIn -ErrorAction SilentlyContinue

#Check if CSV was specified, if not prompt.
If($csvlist -eq $NULL){
    $csvlist = Read-host -Prompt "Csv to import"
}
If((Test-Path $csvlist) -eq $False){Write-host "Could not find CSV.";break}

#Import CSV
$iplist = Import-csv "$csvlist"

#Cycle through each row and add in the ReIP Rule
Foreach ($item in $iplist) {
  $Description = $item.Description
  $Job = $item.Job
  $SourceIp = $item.SourceIp
  $SourceMask = $item.SourceMask
  $TargetIp = $item.TargetIp
  $TargetMask = $item.TargetMask
  $TargetGateway = $item.TargetGateway
  $DNS1 = $item.DNS1
  $DNS2 = $item.DNS2

  $currentiprules = Get-VBRJob -Name $Job | Get-VBRViReplicaReIpRule
  $newiprule = New-VBRViReplicaReIpRule -SourceIp $SourceIp -SourceMask $SourceMask -TargetIp $TargetIp -TargetMask $TargetMask -TargetGateway $TargetGateway -DNS $DNS1,$DNS2 -Description $Description
  $newrules = @($currentiprules) + @($newiprule)
  $replicajob = Get-VBRJob -Name $Job
  Set-VBRViReplicaJob -Job $replicajob -EnableReIp -ReIpRule $newrules

}
