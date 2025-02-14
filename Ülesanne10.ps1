[xml]$customers = Get-Content -Path "F:/Skriptid/customers.xml"



$polandCustomers = $customers.customers.customer | Where-Object { $_.country -eq "Poland" }

foreach ($customer in $polandCustomers) {
    if ($customer.name) {
        Write-Output $customer.name
    } else {
        Write-Output "Name is missing"
    }
}