# Get all local IP addresses
$localIPs = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" | Select-Object -ExpandProperty IPAddress | Where-Object { $_ -ne $null }

# Loop through each local IP address
foreach ($localIP in $localIPs) {

  # Determine the network to scan based on the local IP address
  $network = "$($localIP.Split(".")[0]).$($localIP.Split(".")[1]).$($localIP.Split(".")[2]).0/24"
  Write-Host "Scanning network $network..."

  # Scan the network for available devices
  $devices = nmap -sn $network | Select-String "Nmap scan report for" | ForEach-Object { $_.Line.Split(" ")[4] }

  # Create a list of jobs to run in parallel
  $jobs = @()
  foreach ($device in $devices) {
    $jobs += Start-Job -ScriptBlock {
      Param($device)
      try {
        # Get device information
        $deviceInfo = nmap -O $device | Select-String "Running:"
        $deviceType = ($deviceInfo | Select-String "Device type:").Split(":")[1].Trim()
        $vendor = ($deviceInfo | Select-String "Vendor:").Split(":")[1].Trim()
        $hostname = hostname
        $ip = $device

        # Determine the MIB file
        $mibFile = "$vendor-$deviceType-MIB.txt"
        Write-Host "Downloading MIB file $mibFile..."

        # Check if the MIB file exists in the local cache
        if (!(Test-Path "$env:TEMP\$mibFile")) {
          # Download the MIB file
          Invoke-WebRequest -Uri "http://mibs.observium.org/$mibFile" -OutFile "$env:TEMP\$mibFile"
        }

        # Get the base OID from the MIB file
        $oid = Get-Content "$env:TEMP\$mibFile" | Select-String "OBJECT IDENTIFIER ::=" | Select-String "::=" -List | ForEach-Object { $_.Line } | ForEach-Object { $_.Split("::=")[0].Trim() }
        Write-Host "Base OID: $oid"

        # Perform the snmpwalk
        Write-Host "Performing SNMP walk on $device ($ip)..."
        $result = snmpwalk -Community "public" -OID $oid -ComputerName $ip

        # Write the result to a file
        Set-Content -Path "$env:TEMP\$device.txt" -Value $result

        # Log the result
        Write-EventLog -LogName "Application" -EventId 1111 -Source "SNMP Walk" -EntryType Information -Message "SNMP walk completed successfully for $device ($ip)"
        Write-Host "SNMP walk completed successfully for $device ($ip)"
      }
      catch {
        # Log the error
        Write-EventLog -LogName "Application" -EventId 1112 -Source "SNMP Walk" -EntryType Error -Message "Error occurred while performing SNMP walk for $device ($ip): $_"
        Write-Host "Error occurred while performing SNMP walk for $device ($ip): $_"
      }
    } -ArgumentList $device
  }

  # Wait for all jobs to complete
  Write-Host "Waiting for all jobs to complete..."
  Wait-Job -Job $jobs 

  # Remove all jobs
  Write-Host "Removing all jobs..."
  Remove-Job -Job $jobs | Out-Null
  Write-Host "Finished scanning network $network."

}