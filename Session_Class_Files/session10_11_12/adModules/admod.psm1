function check-aduser{
    param(
        [string]$samaccountname
    )
    return ([bool](Get-ADUser -Filter "SamAccountName -eq '$samaccountname'"))
}
