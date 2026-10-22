

[string[]]$students = @("Atefa","Brenton","Fumika","Michael",100,(Get-Date))

$students.GetType()


Set-Location C:\Users\cevallor\Downloads



[object[]]$allFiles = Get-ChildItem


<#
for($i = 0; $i -lt $allFiles.length; $i++){

    Write-Host $allFiles[$i]    

}



$allServices = Get-Service

$i = 0
while($i -lt $allServices.length){

    #Write-Host $allServices[$i]

    if($allServices[$i] -eq "Dhcp"){
        Write-Host "DHCP service has been found"
    }
    else{}

    $i++

}


$services = Get-Service
$i = 0
while($i -lt $services.Count) {

     if($services[$i].Name -eq "Dhcp") {
        Write-Host "DHCP service has been found, status is: $($services[$i].Status)"
    }
    else{
    }


    $i++
}

do {

    Write-Host "Enter 1"
    Write-Host "Enter 2"
    Write-Host "Enter 3"
    Write-Host "Enter 9 to exit"

    $userChoice = Read-Host "Please enter any number, and enter 9 to exit"

}
until ($userChoice -eq "9")#>


for($hostNumber = 0; $hostNumber -lt 10; $hostNumber++){


    $initialIPAddress = "10.62.28.$hostNumber"

    if(Test-Connection $initialIPAddress -Count 1 -Quiet){
        Write-Host "$initialIPAddress is online" -ForegroundColor Green
    }
    else{
        Write-Host "$initialIPAddress is offline" -ForegroundColor red    
    }

}

Test-Connection "10.62.28.221"

