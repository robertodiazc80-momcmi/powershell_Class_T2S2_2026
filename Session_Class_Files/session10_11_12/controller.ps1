function Get-ADDomainInfo{
    param(
        [string]$addomainProp
    )
    return (Get-ADDomain | Select-Object -Property $addomainProp)
}


function create-aduser{
    
    param(
        [string]$newADUserFirstname,
        [string]$newADUserSurname
    )

    $userfulltname = "$($newADUserFirstname) $($newADUserSurname)"
    $samaccountname = "$($newADUserFirstname).$($newADUserSurname)"

    $domainDNSRoot = Get-ADDomainInfo -addomainProp "DNSRoot"

    $pricipalname = "$($samaccountname)@$($domainDNSRoot.DNSRoot)"  

    New-ADUser -GivenName $newADUserFirstname `
               -Surname $newADUserSurname `
               -Name $userfulltname `
               -SamAccountName $samaccountname `
               -UserPrincipalName $pricipalname `
               -AccountPassword (ConvertTo-SecureString (Read-Host "please enter password") -AsPlainText -Force) `
               -Enabled $true
}




create-aduser `
    -newADUserFirstname (Read-Host "Please enter the first name") `
    -newADUserSurname (Read-Host "Please enter the surname")



