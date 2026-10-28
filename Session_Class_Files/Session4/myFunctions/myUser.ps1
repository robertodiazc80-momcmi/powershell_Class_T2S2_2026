

function Get-UserSummary{

    param(
        [string]$userAccountName,
        [switch]$showUserPasswordInfo = $false
    )

    $userInfo = Get-LocalUser -Name $userAccountName

    if($showUserPasswordInfo){

        $userInfo | Select-Object Name, Enabled, PasswordLastSet, PasswordExpires
    
    }
    else{

        $userInfo | Select-Object Name, Enabled
    }
    
}

