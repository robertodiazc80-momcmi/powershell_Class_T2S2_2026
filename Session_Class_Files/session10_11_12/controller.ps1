function check-aduser{
    param(
        [string]$samaccountname
    )
    return ([bool](Get-ADUser -Filter "SamAccountName -eq '$samaccountname'"))
}

function check-adou{
       param(
        [string]$ouname
    )
    return ([bool](Get-ADOrganizationalUnit -Filter "DistinguishedName -eq 'OU=$($ouname),$((Get-ADDomain).distinguishedName)'"))

}


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


    if (-not (check-aduser -samaccountname $samaccountname )){
        
         New-ADUser -GivenName $newADUserFirstname `
               -Surname $newADUserSurname `
               -Name $userfulltname `
               -SamAccountName $samaccountname `
               -UserPrincipalName $pricipalname `
               -AccountPassword (ConvertTo-SecureString (Read-Host "please enter password") -AsPlainText -Force) `
               -Enabled $true
    
    }
   
}

function create-adou{

    param(
        [string]$newADOUName,
        [string]$newADOUDescription
    )

    if(-not(check-adou -ouname $newADOUName)){
        
        New-ADOrganizationalUnit `
        -Name $newADOUName `
        -path (Get-ADDomain).distinguishedName `
        -Description $newADOUDescription
    
    }    

}



#create-adou -newADOUName "Maintenance" -newADOUDescription "This is a maintenance OU"

write-host (check-adou -ouname "Maintenance2")


$alluserToBeAdded = @(
                        Import-Csv -LiteralPath C:\Users\Administrator\Documents\supportingDocuments\adusers.csv
                    )


foreach($user in $alluserToBeAdded){

    create-aduser `
    -newADUserFirstname ($user).Firstname `
    -newADUserSurname $user.Surname

}

$testou = "HR"

Write-Host "OU=$($testou),$((Get-ADDomain).distinguishedName)"


#create-aduser `
#    -newADUserFirstname (Read-Host "Please enter the first name") `
#    -newADUserSurname (Read-Host "Please enter the surname")

$allOUToBeAdded = @(
                        Import-Csv -LiteralPath C:\Users\Administrator\Documents\supportingDocuments\adusers.csv
                    )


foreach($adou in $allOUToBeAdded){
    
    create-adou -newADOUName $adou.OU -newADOUDescription $adou.Description

}



#======================== Domain Controller promotion =====================

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

Import-Module ADDSDeployment

$adminPass = ConvertTo-SecureString "Password1" -AsPlainText -Force

Install-ADDSForest -CreateDnsDelegation:$false -DomainMode WinThreshold -DatabasePath C:\Windows\NTDS -DomainName "nwk428pss" -DomainNetbiosName "NWK428PSS" -ForestMode WinThreshold -InstallDns:$true -LogPath C:\Windows\NTDS -NoRebootOnCompletion:$false -SysvolPath C:\Windows\SYSVOL -Force:$true -SafeModeAdministratorPassword $adminPass



