<# Session 4 - Functions #>

$PSScriptRoot = Get-Location

. "$PSScriptRoot\myFunctions\myServices.ps1"
. "$PSScriptRoot\myFunctions\myUser.ps1"

.\myFunctions\myServices.ps1
.\myFunctions\myUser.ps1

#Show-SpoolerStatus

#Show-ServiceStatus -serviceName "SysMain"

#Get-UserSummary -userAccountName "Guest" -showUserPasswordInfo $true

#Show-MultipleServicesStatus -serviceNames "WinRm","vds","SmsRouter","Power"


Get-RunningService