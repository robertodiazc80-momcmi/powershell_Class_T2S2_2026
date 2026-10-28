

function Get-MyName{
    return "Roberto"
}


function Show-SpoolerStatus{
    $spoolerStatus = get-service -Name "Spooler"
    write-host "$($spoolerStatus.Name) status is: $($spoolerStatus.Status)"
}


function Show-ServiceStatus{
    param(
        [string]$serviceName    
    )
    $serviceStatus = get-service -Name $serviceName
    write-host "$($serviceStatus.Name) status is: $($serviceStatus.Status)"
}


function Show-MultipleServicesStatus{

    param(
        [string[]]$names
        
    )

    foreach($serviceName in $names){
        $svc = Get-Service -Name $serviceName
        write-host "$($svc.Name) status is: $($svc.Status)"

    }

}


function Get-RunningService{
    param(
        [Parameter(Mandatory)]
        [string]$serviceToQuery    
    )

    $serviceInfo = Get-Service -Name $serviceToQuery

    write-host "Service to query: $($serviceInfo.Status)"

}




