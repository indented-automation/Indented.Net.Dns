function Get-DnsServerList {
  # .SYNOPSIS
  #   Gets a list of network interfaces and attempts to return a list of DNS server IP addresses.
  # .DESCRIPTION
  #   Get-DnsServerList uses System.Net.NetworkInformation to return a list of operational ethernet or wireless interfaces. IP properties are returned, and an attempt to return a list of DNS server addresses is made. If successful, the DNS server list is returned.
  # .OUTPUTS
  #   System.Net.IPAddress[]
  # .EXAMPLE
  #   Get-DnsServerList
  # .EXAMPLE
  #   Get-DnsServerList -IPv6
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     04/09/2012 - Chris Dent - Created.
  
  [CmdLetBinding()]
  param(
    [Switch]$IPv6
  )

  if ($IPv6) {
    $AddressFamily = [Net.Sockets.AddressFamily]::InterNetworkv6
  } else {
    $AddressFamily = [Net.Sockets.AddressFamily]::InterNetwork
  }
  
  if ([Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()) {
    [Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces() |
      Where-Object { $_.OperationalStatus -eq 'Up' -and $_.NetworkInterfaceType -match 'Ethernet|Wireless' } |
      ForEach-Object { $_.GetIPProperties() } |
      Select-Object -ExpandProperty DnsAddresses -Unique |
      Where-Object AddressFamily -eq $AddressFamily
  }
}

