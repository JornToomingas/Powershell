Import-Module ActiveDirectory

$domain = Get-ADDomain
$domainDN = $domain.DistinguishedName
$dnsRoot = $domain.DNSRoot

$targetOU = "OU=KASUTAJAD,$domainDN"

$users = Import-Csv C:\Skriptid\kasutajad.csv

foreach ($user in $users) {

    $username = "$($user.FirstName.ToLower()).$($user.LastName.ToLower())"

    $password = ConvertTo-SecureString $user.Password -AsPlainText -Force

    if (-not (Get-ADUser -Filter "SamAccountName -eq '$username'" -ErrorAction SilentlyContinue)) {

        New-ADUser `
            -Name "$($user.FirstName) $($user.LastName)" `
            -GivenName $user.FirstName `
            -Surname $user.LastName `
            -SamAccountName $username `
            -UserPrincipalName "$username@$dnsRoot" `
            -Path $targetOU `
            -AccountPassword $password `
            -Enabled $true `
            -ChangePasswordAtLogon $true

        Write-Host "Kasutaja loodud: $username"
    }
    else {
        Write-Host "Kasutaja juba olemas: $username"
    }
}
