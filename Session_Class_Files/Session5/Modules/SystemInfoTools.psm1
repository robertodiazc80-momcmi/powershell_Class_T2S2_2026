

# This function is publically accessible.

function Get-All-My-ComputerInfo{
    
    param(    
        [string]$propertyToGet
    )

    if([string]::IsNullOrWhiteSpace($propertyToGet)){
        $propertyToGet = "WindowsVersion"
    }


    return (Fetch-ComputerInfo -computerProperty $propertyToGet)
}




# This function is private and only accessible via Module
function Fetch-ComputerInfo {
   
   param(
        [string]$computerProperty
   )

   return (Get-ComputerInfo | Select-Object $computerProperty)

}




function Get-MyName{
    return "Roberto"
}


Export-ModuleMember -Function @('Get-All-My-ComputerInfo','Get-MyName')