class DnsPrimaryZone : DnsZone {
    # Aging and scavenging

    [Boolean]           $Aging
    [ZoneDynamicUpdate] $DynamicUpdate
    [DateTime]          $AvailForScavengeTime
    [TimeSpan]          $NoRefreshInterval
    [TimeSpan]          $RefreshInterval
    [String[]]          $ScavengeServers

    # Zone Transfer

    [ZoneTransfer]      $ZoneTransfer
    [String[]]          $SecondaryServers
    [Notify]            $Notify
    [String[]]          $NotifyServers

    # WINS

    [Boolean]           $DisableWINSRecordReplication

    DnsPrimaryZone([CimInstance]$CimInstance) : base($CimInstance) { }

    Hidden [Void] UpdateProperties() {
        $this.Aging = $this.CimInstance.Aging
        $this.DynamicUpdate = $this.CimInstance.AllowUpdate

        if ($this.CimInstance.AvailForScavengeTime -ne 0) {
            $this.AvailForScavengeTime = [DateTime]::new(1601, 1, 1).AddHours(
                $this.CimInstance.AvailForScavengeTime
            )
        }

        $this.NoRefreshInterval = [TimeSpan]::new($this.CimInstance.NoRefreshInterval)
        $this.RefreshInterval = [TimeSpan]::new($this.CimInstance.RefreshInterval)
        $this.ScavengeServers = $this.CimInstance.ScavengeServers

        $this.ZoneTransfer = $this.CimInstance.SecureSecondaries
        $this.SecondaryServers = $this.CimInstance.SecondaryServers
        $this.Notify = $this.CimInstance.Notify
        $this.NotifyServers = $this.CimInstance.NotifyServers

        $this.DisableWINSRecordReplication = $this.CimInstance.DisableWINSRecordReplication
        $this.UseWins = $this.CimInstance.UseWins
    }

    # This method call will fail if:
    #   NodeName is not fully-qualified or @
    #   NodeName does not exist
    [Void] AgeAllRecords(
        [String]  $nodeName,
        [Boolean] $applyToSubtree
    ) {
        if ($nodeName -ne '@' -and -not $nodeName.ToLower().Contains($this.ZoneName.ToLower())) {
            throw 'InvalidNodeName'
        }

        # Work on this
        $this.CimInstance | Invoke-CimMethod -MethodName 'AgeAllRecords' -Arguments @{
            ApplyToSubtree = $applyToSubtree
            NodeName       = $nodeName
        }
    }

    [String] GetDistinguishedName() {
        return $this.CimInstance | Invoke-CimMethod -MethodName 'GetDistinguishedName'
    }
}