Import-Module ActiveDirectory -ErrorAction SilentlyContinue
Import-Module GroupPolicy -ErrorAction SilentlyContinue
Import-Module DhcpServer -ErrorAction SilentlyContinue
Import-Module ServerManager -ErrorAction SilentlyContinue

$script:Raport = @()

function Lisa-Tulemus {
    param($Kategooria,$Kontroll,$Staatus)

    $script:Raport += [PSCustomObject]@{
        Kategooria = $Kategooria
        Kontroll   = $Kontroll
        Staatus    = $Staatus
    }
}

function Testi($tingimus){
    if($tingimus){ "TEHTUD" }
    else{ "TEGEMATA" }
}

# ==============================
# BAASVORK
# ==============================

$Server = $env:COMPUTERNAME
Lisa-Tulemus "Baasvork" "Serveri nimi on AD1" (Testi ($Server -eq "AD1"))

$IP = (Get-NetIPAddress -AddressFamily IPv4 | Where {$_.IPAddress -like "10.0.*"}).IPAddress
Lisa-Tulemus "Baasvork" "IP aadress kujul 10.0.xxx.10" (Testi ($IP -like "10.0.*.10"))

$Domain = Get-ADDomain -ErrorAction SilentlyContinue
Lisa-Tulemus "Baasvork" "Domeen olemas" (Testi $Domain)

# ==============================
# OU STRUKTUUR
# ==============================

$Oud = "KASUTAJAD","LEKTORID","TUDENGID","ARVUTID"

foreach($ou in $Oud){
    $olemas = Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -ErrorAction SilentlyContinue
    Lisa-Tulemus "Active Directory" "$ou OU olemas" (Testi $olemas)
}

# ==============================
# GRUPID
# ==============================

$Grupid = "Lektorid","Tudengid","RedirectedDirectories"

foreach($g in $Grupid){
    $olemas = Get-ADGroup -Filter "Name -eq '$g'" -ErrorAction SilentlyContinue
    Lisa-Tulemus "Grupid" "$g grupp olemas" (Testi $olemas)
}

# ==============================
# KASUTAJAD
# ==============================

$Kasutajad = "oppejoud1","oppejoud2","tudeng1","tudeng2"

foreach($k in $Kasutajad){
    $olemas = Get-ADUser -Filter "SamAccountName -eq '$k'" -ErrorAction SilentlyContinue
    Lisa-Tulemus "Kasutajad" "$k kasutaja olemas" (Testi $olemas)
}

$Lektor = Get-ADGroupMember "Lektorid" -ErrorAction SilentlyContinue
$Tudeng = Get-ADGroupMember "Tudengid" -ErrorAction SilentlyContinue

Lisa-Tulemus "Kasutajad" "oppejoud1 Lektorid grupis" (Testi ($Lektor.SamAccountName -contains "oppejoud1"))
Lisa-Tulemus "Kasutajad" "oppejoud2 Lektorid grupis" (Testi ($Lektor.SamAccountName -contains "oppejoud2"))
Lisa-Tulemus "Kasutajad" "tudeng1 Tudengid grupis" (Testi ($Tudeng.SamAccountName -contains "tudeng1"))
Lisa-Tulemus "Kasutajad" "tudeng2 Tudengid grupis" (Testi ($Tudeng.SamAccountName -contains "tudeng2"))

# ==============================
# SERVERI ROLLID
# ==============================

$Rollid = "AD-Domain-Services","DHCP","DNS","WDS","Web-Server"

foreach($r in $Rollid){
    $inst = Get-WindowsFeature $r
    Lisa-Tulemus "Serveri rollid" "$r paigaldatud" (Testi $inst.Installed)
}

# ==============================
# DHCP
# ==============================

$scope = Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Where {$_.Name -eq "HKHK"}
Lisa-Tulemus "DHCP" "Skoop HKHK olemas" (Testi $scope)

# ==============================
# FAILISERVER / DFS
# ==============================

$kaust1 = Test-Path "F:\DFS_Lektoritele"
$kaust2 = Test-Path "F:\DFS_Tudengitele"

Lisa-Tulemus "Failiserver" "DFS_Lektoritele kaust olemas" (Testi $kaust1)
Lisa-Tulemus "Failiserver" "DFS_Tudengitele kaust olemas" (Testi $kaust2)

$dfs = Get-DfsnRoot -ErrorAction SilentlyContinue | Where {$_.Path -like "*Tudengid"}
Lisa-Tulemus "DFS" "DFS nimeruum Tudengid olemas" (Testi $dfs)

# ==============================
# GPO
# ==============================

$GPOd = "7zip","Chrome","Wallpaper"

foreach($g in $GPOd){
    $olemas = Get-GPO -Name $g -ErrorAction SilentlyContinue
    Lisa-Tulemus "Group Policy" "$g GPO olemas" (Testi $olemas)
}

# ==============================
# LAPS
# ==============================

$laps = Get-Command -Module Microsoft.Windows.LAPS -ErrorAction SilentlyContinue
Lisa-Tulemus "Turvalisus" "LAPS paigaldatud" (Testi $laps)

# ==============================
# PROTSENT
# ==============================

$Kokku = $script:Raport.Count
$Tehtud = ($script:Raport | Where {$_.Staatus -eq "TEHTUD"}).Count

if ($Kokku -gt 0) {
    $Protsent = [math]::Round(($Tehtud / $Kokku) * 100, 2)
}
else {
    $Protsent = 0
}

# ==============================
# HTML RAPORT
# ==============================

$Path = "C:\KursuseRaport.html"

$HTML = @"
<html>
<head>
<title>Kursuse raport</title>
<style>
body{font-family:Arial;background:#f4f6f8;padding:20px;}
table{border-collapse:collapse;width:100%;background:white;}
th{background:#2c3e50;color:white;padding:10px;}
td{border:1px solid #ddd;padding:8px;text-align:center;}
.TEHTUD{background:#c8f7c5;font-weight:bold;}
.TEGEMATA{background:#f7c5c5;font-weight:bold;}
h1{color:#2c3e50;}
</style>
</head>
<body>

<h1>Kursuse progressi raport</h1>
<p>Kuupaev: $(Get-Date)</p>

<table>
<tr>
<th>Kategooria</th>
<th>Kontroll</th>
<th>Staatus</th>
</tr>
"@

foreach($r in $script:Raport){

$HTML += "<tr>"
$HTML += "<td>$($r.Kategooria)</td>"
$HTML += "<td>$($r.Kontroll)</td>"
$HTML += "<td class='$($r.Staatus)'>$($r.Staatus)</td>"
$HTML += "</tr>"

}

$HTML += "</table>"

$HTML += "<h2>Taitmise protsent: $Protsent %</h2>"

$HTML += "</body></html>"

$HTML | Out-File $Path -Encoding UTF8

Start-Process $Path

Write-Host ""
Write-Host "Raport loodud: $Path"
Write-Host "Taitmine:" $Protsent "%"
