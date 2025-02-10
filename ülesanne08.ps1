#1. funktsioon ringi pindala
function Get-CircleArea {
    param (
        [double]$Radius
    )
    $Area = [Math]::PI * [Math]::Pow($Radius, 2)
    return $Area
}

$radius = 5
$area = Get-CircleArea -Radius $radius
Write-Output "Ringi pindala raadiusega $radius on $area"


#2. funktsioon täisnimi
function Format-FullName {
    param (
    [string]$FullName
)

$cleanedName = $FullName -replace '[äöõüÄÖÕÜ]',''

$cleanedName = $cleanName.Trim() 

$cleanedName = $cleanName -split ' ' | ForEach-Object { 
    if ($_ -ne '') {
    $_.Substring(0, 1).ToUpper() + $_.Substring(1).ToLower()
    }
}

return -join $cleanedName
}



$nimi = "Ülo Ööbik"
$puhastatudNimi = Format-FullName -FullName $nimi
Write-Output "Puhastatud nimi on: $puhastatudNimi"