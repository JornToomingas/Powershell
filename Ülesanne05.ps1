Clear-Host

Write-Output "Masina nimi (Host Name):"
Write-Output "**********"
$hostname = hostname
Write-Output $hostname
Write-Output "**********"

Write-Output "Operatsioonisüsteem (OS name):"
Write-Output "**********"
$os = Get-WmiObject -Class Win32_OperatingSystem
Write-Output $os.Caption
Write-Output "**********"

Write-Output "IP address (netipaddress, netadapter):"
Write-Output "**********"
$ipaddress = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.IPEnabled -eq $true} | Select-Object -ExpandProperty IPAddress
Write-Output $ipaddress
Write-Output "**********"

Write-Output "Muutmälu suurus (RAM):"
Write-Output "**********"
$ram = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
$ramGB = [math]::round($ram / 1GB, 2)
Write-Output "$ramGB GB"
Write-Output "**********"

Write-Output "Protsessori nimi (Processor, CPU):"
Write-Output "**********"
$cpu = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
Write-Output $cpu
Write-Output "**********"

Write-Output "Graafikakaardi nimi (VideoController):"
Write-Output "**********"
$gpu = Get-WmiObject -Class Win32_VideoController | Select-Object -ExpandProperty Name
Write-Output $gpu
Write-Output "**********"

Write-Output "Arvuti kasutajate nimed (UserAccount):"
Write-Output "**********"
$users = Get-WmiObject -Class Win32_UserAccount | Select-Object -ExpandProperty Name
foreach ($user in $users) {
Write-Output $users
}
Write-Output "**********"