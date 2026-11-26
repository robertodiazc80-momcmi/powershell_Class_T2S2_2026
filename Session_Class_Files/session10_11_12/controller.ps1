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

create-adou -newADOUName "HR" -newADOUDescription "HR OU"

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


Get-NetIPAddress

Set-DnsClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses 192.168.20.3

get-service DNS | Select-Object name,displayname,status

set-service -Name DNS -StartupType Automatic

Get-DnsServerZone | Where-Object {

    $_.Zonename -notlike "*.arpa"
}


Add-DnsServerPrimaryZone `
    -NetworkId "192.168.20.0/24" `
    -ReplicationScope Domain `
    -DynamicUpdate Secure



Get-DnsServerZone | Where-Object {

    $_.Zonename -like "*168.192.in-addr.arpa"
}


Add-DnsServerResourceRecordPtr `
-ZoneName "20.168.192.in-addr.arpa" `
-Name "3" `
-PtrDomainName "Server1.nwk428pss.local"


Get-DnsServerResourceRecord -ZoneName "20.168.192.in-addr.arpa"


create-aduser -newADUserFirstname "Sean" -newADUserSurname "Reschke"

Get-ADUser -filter "*"

#============================== GPO ================================


$gpoName = "Disable Control Panel"

New-GPO -Name $gpoName -Comment "This GPO disables the Control Panel for a client"

Set-GPRegistryValue -Name $gpoName `
-Key "HKCU\software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
-ValueName "NoControlPanel" `
-Type DWord `
-Value 1


OU=HR,DC=nwk428pss,DC=local

 

New-GPLink -Name $gpoName -Target "OU=HR,$((Get-ADDomain).DistinguishedName)"


function configure-dhcp-service{

    $networkIp = "192.168.20.0"

    
    function get-this-srvrIPAddr{    
        
      return ((Get-NetIPAddress -AddressFamily IPv4) | Where-Object {
            $_.InterfaceAlias -notlike "*Loopback*"

        }).IPAddress    
    
    }
    
    function get-dhcp-windowsFeature{
    
        $feature = Get-WindowsFeature -Name DHCP
        
        if(-not $feature.Installed -eq $true){
            Install-WindowsFeature -Name DHCP -IncludeManagementTools -verbose
            Write-Host "dhcp feature installed" -ForegroundColor Green
        }    
    
    }


    function authorize-this-server{    
        Add-DhcpServerInDC -dnsname ((Get-ADDomain).InfrastructureMaster) `
        -IPAddress (get-this-srvrIPAddr)    
    }


    function set-ipranges-forClients{
    
        Add-dhcpserverv4scope `
        -name $networkIp `
        -startrange "192.168.20.80" `
        -endrange "192.168.20.100" `
        -subnetMask = "255.255.255.0" `
        -state active   
    
    }

    function set-dhcp-client-option{
        
        -scopeid $networkIp `
        -dnsserver (get-this-srvrIPAddr) `
        -dnsDomain ((Get-ADForest).rootdomain)
    
    }

    # called 1stfunction check-aduser{
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

create-adou -newADOUName "HR" -newADOUDescription "HR OU"

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


Get-NetIPAddress

Set-DnsClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses 192.168.20.3

get-service DNS | Select-Object name,displayname,status

set-service -Name DNS -StartupType Automatic

Get-DnsServerZone | Where-Object {

    $_.Zonename -notlike "*.arpa"
}


Add-DnsServerPrimaryZone `
    -NetworkId "192.168.20.0/24" `
    -ReplicationScope Domain `
    -DynamicUpdate Secure



Get-DnsServerZone | Where-Object {

    $_.Zonename -like "*168.192.in-addr.arpa"
}


Add-DnsServerResourceRecordPtr `
-ZoneName "20.168.192.in-addr.arpa" `
-Name "3" `
-PtrDomainName "Server1.nwk428pss.local"


Get-DnsServerResourceRecord -ZoneName "20.168.192.in-addr.arpa"


create-aduser -newADUserFirstname "Sean" -newADUserSurname "Reschke"

Get-ADUser -filter "*"

#============================== GPO ================================


$gpoName = "Disable Control Panel"

New-GPO -Name $gpoName -Comment "This GPO disables the Control Panel for a client"

Set-GPRegistryValue -Name $gpoName `
-Key "HKCU\software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
-ValueName "NoControlPanel" `
-Type DWord `
-Value 1


OU=HR,DC=nwk428pss,DC=local

 

New-GPLink -Name $gpoName -Target "OU=HR,$((Get-ADDomain).DistinguishedName)"



function configure-dhcp-service{

    $networkIp = "192.168.20.0"

    
    function get-this-srvrIPAddr{    
        
      return ((Get-NetIPAddress -AddressFamily IPv4) | Where-Object {
            $_.InterfaceAlias -notlike "*Loopback*"

        }).IPAddress    
    
    }
    

    function get-dhcp-windowsFeature{
    
        $feature = Get-WindowsFeature -Name DHCP
        
        if(-not $feature.Installed -eq $true){
            Install-WindowsFeature -Name DHCP -IncludeManagementTools -verbose
            Write-Host "dhcp feature installed" -ForegroundColor Green
        }    
    
    }


    function authorize-this-server{    
        Add-DhcpServerInDC -dnsname ((Get-ADDomain).InfrastructureMaster) `
        -IPAddress (get-this-srvrIPAddr)    
    }


    function set-ipranges-forClients{
            
        Add-DhcpServerv4Scope -Name "ClientIPaddresses" `
        -StartRange "192.168.20.20" `
        -EndRange "192.168.20.30" `
        -SubnetMask "255.255.255.0" `
        -State Active
          
    
    }

    function set-dhcp-client-option{

        Set-DhcpServerv4OptionValue `
        -ScopeId $networkIp `       
        -DnsServer $(get-this-srvrIPAddr) `
        -dnsDomain ((Get-ADForest).RootDomain)
    
    }

    # called 1st
    write-host "Running install windows feature"
    get-dhcp-windowsFeature
    
    # called 2nd
    write-host "Running authorize"
    authorize-this-server
    
    # called 3rd
    write-host "Running ipranges"
    set-ipranges-forClients

    # called 4th 
    write-host "Running client option"
    set-dhcp-client-option

    # called 5th
    write-host "restarting"
    #Restart-Service dhcp

}




#configure-dhcp-service



function create-task{

    $actionToBePerformed = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument "-executionPolicy ByPass -File C:\sourceDirectory\taskToRun.ps1"


    $taskTrigger = New-ScheduledTaskTrigger `
        -Daily -At 8:16PM


    $taskPricipal = New-ScheduledTaskPrincipal `
        -UserId "SYSTEM" -RunLevel Highest


    $task = New-ScheduledTask `
        -Action $actionToBePerformed `
        -Trigger $taskTrigger `
        -Principal $taskPricipal


    Register-ScheduledTask -TaskName "Backup Files" -InputObject $task

}

#create-task

function get-failed-loggins{

    $startTimeOfScope = (get-date).AddHours(-24)

    $failedEvents = Get-WinEvent `
                -FilterHashtable `
                    @{ 
                        LogName = 'Security'
                        ID = 4625 
                        StartTime = $startTimeOfScope
                    }
                      
   
   $failedEvents | Select-Object TimeCreated,
        @{Name="Username";Expression={$_.Properties[5].value}},
        @{Name="IPAddress";Expression={$_.Properties[19].value}},
        @{Name="FailureReason";Expression={$_.Properties[8].value}} | Format-Table -AutoSize


}


get-failed-loggins



