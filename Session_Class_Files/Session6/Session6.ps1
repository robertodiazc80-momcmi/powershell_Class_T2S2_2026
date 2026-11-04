cls

$bunchOfServices = "Spooler","W32Time", "RobertoITService"


#Write-Host "Errors tally: $($Error.Count)"
<#
try{
    # The try block allows us to run code that may result in an error.

    Get-Service -Name $bunchOfServices -ErrorAction stop

}

catch [Microsoft.PowerShell.Commands.ServiceCommandException]{
    
    $errorCaughtMessage = $_.Exception.Message
    $errorCaughtType = $_.Exception.gettype().fullname
    $errorCaughtSourceLineNumber = $_.InvocationInfo.ScriptLineNumber


    write-host "An error has occured whilst getting a service, the error message is: $($errorCaughtMessage)" -ForegroundColor Red
    write-host "The error type is: $($errorCaughtType)" -ForegroundColor yellow
    Write-host "The actual error occurred in line: $($errorCaughtSourceLineNumber)" -ForegroundColor Gray
}

catch{
    # The catch block 'catches' errors that have occurred in the TRY{} block    
}

finally{
    # Run code regardless of an error occurring.
    
    Write-Host "Process has now finished - regardless if an error has occurred!"
     
}
#>

function Write-Errors-To-log{
    param(
        [string]$errorMessage
    )
    $logFileName = "logs.txt"
    $timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFileName -Value "[$($timestamp)] - $($errorMessage)" 
}



try{
    Get-ChildItem -Path "RobertoDir" -ErrorAction stop
}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "Error message caught $($_.Exception.Message)"
    Write-Host "Type of error: $($_.Exception.gettype().fullname)"
    Write-Host "Directory does not exists in current working directory" -ForegroundColor Yellow
    Write-Errors-To-log -errorMessage $_.Exception.Message
}
finally{
    

}



