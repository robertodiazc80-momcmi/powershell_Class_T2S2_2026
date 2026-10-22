<# Session 3 - 22/10/2026 [Inputs, outputs and pipelines]

    Repo addres: https://github.com/robertodiazc80-momcmi/powershell_Class_T2S2_2026.git



#>

Get-Command -Verb Get

Get-Help Get-ComputerInfo

Get-TimeZone


Remove-Item * -WhatIf

Set-Location C:\Users\cevallor\Downloads

"Roberto Cevallos" | Out-File -FilePath lecturersName.txt

Get-ChildItem -Path C:\Users\cevallor\Downloads\*.ps1 | Format-Table


Get-ChildItem -Path C:\Users\cevallor\Downloads\*.ps1 | Out-File -FilePath allPS1Files.txt


Measure-Command {
    $myComputerInfo = Get-ComputerInfo
    foreach($x in $myComputerInfo){
    
        Write-Host $x.OsOrganization
        Write-Host $x.TimeZone

    }
}


Measure-Command {

    Get-ComputerInfo | Select-Object "OsOrganization","TimeZone"

}


Get-Service | Select-Object -Last 10



Measure-Command {

    get-service | Where-Object Status -EQ "Stopped"

 } | Select-Object TotalMilliseconds



Measure-Command {

    get-service | Where-Object {
        $_.Status -eq "Stopped" -and $_.Name -eq "WinRM"
    }

 } | Select-Object TotalMilliseconds



 # 1. Find out all services available
 # 2. Find out the first 20 services
 # 3. Out of the first 20 services, which ones have stopped


 Get-Service | Select-Object -First 20 | Where-Object {
 
    $_.Status -eq "Stopped"
 
 } | Out-File -FilePath stoppedServices.txt


 get-service | ForEach-Object {
    Write-Host $_.Name
 }










