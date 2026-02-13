Import-Module ActiveDirectory

# Muuda true falseiks kui proovid kustutada.
$DryRun = $true

$domain = Get-ADDomain
$domainDN = $domain.DistinguishedName

$limitDate = (Get-Date).AddYears(-1)

$disabledOU = "OU=DISABLED,OU=KASUTAJAD,$domainDN"

$users = Get-ADUser -Filter * `
    -SearchBase "OU=KASUTAJAD,$domainDN" `
    -Properties LastLogonDate, MemberOf, Enabled

foreach ($user in $users) {

    if ($user.SamAccountName -eq "Administrator") { continue }

    if ($user.MemberOf -match "Domain Admins") { continue }

    if (($user.LastLogonDate -eq $null) -or ($user.LastLogonDate -lt $limitDate)) {

        Write-Host "Mitteaktiivne kasutaja leitud:" $user.SamAccountName

        if (-not $DryRun) {

            Disable-ADAccount -Identity $user

            Move-ADObject `
                -Identity $user.DistinguishedName `
                -TargetPath $disabledOU

            Write-Host "Keelatud ja liigutatud DISABLED OU-sse"
        }
        else {
            Write-Host "DRY RUN: muudatusi ei tehtud"
        }
    }
}
