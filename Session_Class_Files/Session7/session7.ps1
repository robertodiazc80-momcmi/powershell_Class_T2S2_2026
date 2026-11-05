
# What are we going to do: Create a function that gets a service based on the service name

function Get-ServiceByName {
    <#
        .SYNOPSIS
            Getting a Windows OS service by service
        .DESCRIPTION
            Accepts a string and string must be a service name. Reject anything other than a string.
            IF a string is passed, the Get-Service cmdlet is executed in conjunction with the service name.
            If service is found, returns service information
        .PARAMETER - ServiceName
            The service name of the service we are trying to query.
        .EXAMPLE
            Get-Service -ServiceName "Spooler"
        .OUTPUTS
            Service information
    #>

    param(
        [Parameter(Mandatory)]
        $serviceName
    )


    Check-If-String -inputToTest $serviceName


    if(Check-If-String -inputToTest $serviceName){    
            
        if([string]::IsNullOrWhiteSpace($serviceName)){
            Write-Host "The service name cannot be null or have a space within it" -ForegroundColor yellow
        }

        # * [ ] ?

        if($serviceName -match '[\*\[\]\?]'){
            Write-Host "The service name cannot have any special characters in it" -ForegroundColor Red
        }


        try{
            Get-Service -Name $serviceName -ErrorAction Stop
        }
        catch{
    
            $errorMessageCaught = $_.Exception.Gettype().name
            Write-Host "The error that was caught was of type $($errorMessageCaught)"

        }
    
    }





}

function Check-If-String{

    param(
        $inputToTest
    )
    
    if($inputToTest -isnot [string] ){
        Write-Host "The service name that you have entered is not a string because it is $($serviceName.Gettype().name)" -ForegroundColor Red
        $returnedResult = $false
    }
    else{
        $returnedResult = $true
    }

    return $returnedResult
}

Get-ServiceByName -serviceName 123