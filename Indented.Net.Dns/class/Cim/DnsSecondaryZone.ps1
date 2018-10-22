class DnsSecondaryZone : DnsZone {
    [DateTime]     $LastSuccessfulSoaCheck
    [DateTime]     $LastSuccessfulXfr
    [String[]]     $MasterServers
    [String[]]     $LocalMasterServers

    # Zone Transfer

    [ZoneTransfer] $ZoneTransfer
    [String[]]     $SecondaryServers
    [Notify]       $Notify
    [String[]]     $NotifyServers

    DnsSecondaryZone([CimInstance]$CimInstance) : base($CimInstance) { }

    Hidden [Void] UpdateProperties() {
        if ($this.CimInstance.LastSuccessfulSoaCheck -ne 0) {
            $this.LastSuccessfulSoaCheck = [DateTime]::new(1970, 1, 1).AddSeconds(
                $this.CimInstance.LastSuccessfulSoaCheck
            )
        }
        if ($this.CimInstance.LastSuccessfulXfr -ne 0) {
            $this.LastSuccessfulXfr = [DateTime]::new(1970, 1, 1).AddSeconds(
                $this.CimInstance.LastSuccessfulXfr
            )
        }

        $this.MasterServers = $this.CimInstance.MasterServers
        $this.LocalMasterServers = $this.CimInstance.LocalMasterServers
        
        $this.ZoneTransfer = $this.CimInstance.SecureSecondaries
        $this.SecondaryServers = $this.CimInstance.SecondaryServers
        $this.Notify = $this.CimInstance.Notify
        $this.NotifyServers = $this.CimInstance.NotifyServers
    }
}