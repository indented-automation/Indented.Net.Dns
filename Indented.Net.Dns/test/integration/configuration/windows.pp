# win_dns
# =======
#
# Configures a Windows-based DNS server for testing.
#
class win_dns {
  dsc_windowsfeature { 'dns_server':
    dsc_ensure               => 'present',
    dsc_name                 => 'DNS',
    dsc_includeallsubfeature => true,
  }

  file { 'c:/windows/system32/dns/domain.example.dns':
    ensure  => present,
    content => epp('winbeats/win_domain.example.dns.epp', $facts['hostname']),
  }
}
