$kasutajad = Import-Csv -Path "F:\Skriptid\users.csv"

$uuskasutajad = @()

function Genereeri-Parool {
    param (
        [string]$perekonnanimi
    )
    $perekonnaosa = $perekonnanimi.Substring(0, 3).ToLower()
    $numbriteosa = -join ((0..9) | Get-Random -Count 2)
    return $perekonnaosa + $numbriteosa
}

foreach ($kasutaja in $kasutajad) {
    $eesnimi = $kasutaja.eesnimi
    $perekonnanimi = $kasutaja.perenimi

    $nimi = "$eesnimi $perekonnanimi"
    $kasutajanimi = ($eesnimi.Substring(0, 1) + $perekonnanimi).ToLower()
    $email = "$eesnimi.$perekonnanimi@hkhk.edu.ee"
    $parool = Genereeri-Parool -perekonnanimi $perekonnanimi



    $uusKasutaja = [PSCustomObject]@{
        Nimi         = $nimi
        Kasutajanimi = $kasutajanimi
        Email        = $email
        Parool       = $parool
    }
    $uusKasutajad += $uusKasutaja
}


$uusKasutajad | Export-Csv -Path "F:\Skriptid\uued_kasutajad.csv"

Write-Host "Uus csv fail on tehtud: uued_kasutajad.csv"

