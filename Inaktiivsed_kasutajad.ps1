Import-Module ActiveDirectory

$inactiveOU = "OU=INAKTIIVSED KASUTAJAD,DC=TOOMINGAS,DC=LOCAL"
$Aasta = (Get-Date).AddYears(-1)

$users = Get-ADUser -Filter * -Properties LastLogonDate

foreach ($user in $users) {
    if ($user.LastLogonDate -eq $null -or $user.LastLogonDate -lt $oneYearAgo) {
        Move-ADObject -Identity $user.DistinguishedName -TargetPath $inactiveOU
        Disable-ADAccount -Identity $user.SamAccountName
        Write-Output "Kasutaja $($user.SamAccountName) on liigutatud ja deaktiveeritud."
    }
}