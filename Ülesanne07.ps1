#Arvuti nimi
Write-Host "Arvuti nimi: $env:COMPUTERNAME"

#kettaste leidmine
$drives = Get-PSDrive -PSProvider FileSystem
Write-Host "Loogiliste ketaste koguarv: $($drives.Count)"

#ketaste vabaruumi %
foreach ($drive in $drives) {
    if ($drive.Used -ne $null -and $drive.Free -ne $null) {
        $freeSpacePercent = [math]::Round(($drive.Free / ($drive.Used + $drive.Free)) * 100, 2)
        Write-Host "Ketas $($drive.Name): Vaba ruumi protsent - $freeSpacePercent%"
        if ($freeSpacePercent -lt 50 {
            Write-Host "Hakkab täis saama"
        }
    } else {
        Write-Host "Ketas $($Drive.Name): Kogumaht on null, ei saa arvutada vaba ruumi protsenti."
        }
    }
}