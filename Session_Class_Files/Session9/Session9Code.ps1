
function Get-Service-Property-By-Name{


    param(
        [Parameter(Mandatory)]    
        [string]$serviceName,
        [ValidateSet('Status','Name','DisplayName')]
        [string]$serviceNameProperty
    )

    $serviceInformation = Get-service -Name $serviceName -ErrorAction stop    
    
    return $serviceInformation.$serviceNameProperty


}

#Get-Service-Property-By-Name -serviceName "winrm" -serviceNameProperty Status


function Get-Service-Status-By-Name{

    param(
        [Parameter(Mandatory)] 
        [string]$serviceName
    )

    $statusResult = Get-Service-Property-By-Name -serviceName $serviceName -serviceNameProperty Status

    return $statusResult
}

#Get-Service-Status-By-Name -serviceName "Spooler"


function Test-PSRemotingEnabled{

    param(
        [Parameter(Mandatory)] 
        [string]$computer
    )

    try{
        Test-WSMan -ComputerName $computer -ErrorAction stop | Out-Null
        return $true
    }
    catch{
        return $false
    }
}



if(Test-PSRemotingEnabled -computer 127.0.0.1){
    Write-Host "PSRemoting is in fact enabled" -ForegroundColor Green
}
else{
    Enable-PSRemoting -Force
    Write-Host "PSRemoting is now enabled" -ForegroundColor Green

}

# This code is generally executed within the server's memory e.g. Invoke-Command in the server.

$result = Invoke-Command -ComputerName 192.168.20.3 -Credential (Get-Credential) -ScriptBlock {

    function Test-PSRemotingEnabled-Server{
        param(
            [Parameter(Mandatory)] 
            [string]$computer
        )

        try{
            Test-WSMan -ComputerName $computer -ErrorAction stop | Out-Null
            return $true
        }
        catch{
            return $false
        }
    }
    

    if(Test-PSRemotingEnabled-Server -computer 127.0.0.1){
        Write-Host "PSRemoting is in fact enabled" -ForegroundColor Yellow
    }
    else{
        Enable-PSRemoting -Force
        Write-Host "PSRemoting is now enabled" -ForegroundColor Blue

    }

}

Write-Host $result