using namespace System.Management.Automation

class DnsZone {
    # Zone name

    [String]   $ZoneName
    [Boolean]  $AutoCreated
    [String]   $DataFile
    [String]   $DnsServerName

    # Zone type

    [ZoneType] $ZoneType
    [Boolean]  $DsIntegrated
    [Boolean]  $Reverse

    # Zone State

    [Boolean]  $Paused
    [Boolean]  $Shutdown

    Hidden [CimInstance] $CimInstance

    DnsZone() { }
    DnsZone([CimInstance]$instance) {
        $this.CimInstance = $instance

        $this.ZoneName = $instance.Name
        $this.AutoCreated = $instance.AutoCreated
        $this.DataFile = $instance.DataFile
        $this.DnsServerName = $instance.DnsServerName
        $this.ZoneType = $instance.ZoneType
        $this.DsIntegrated = $instance.DsIntegrated
        $this.Reverse = $instance.Reverse
        $this.Paused = $instance.Paused
        $this.Shutdown = $instance.Shutdown

        $this.UpdateProperties()
    }

    Hidden [Void] UpdateProperties() { }

    # ChangeZoneType
    #
    # Error Codes for ChangeZoneType:
    # Argument Error Codes:
    # 1 - IP Address List is mandatory for Secondary, Stub and Forwarder
    # 2 - Cannot change Stub or Forwarder to Primary
    # 3 - Cannot convert Shutdown or Expired zone to Primary
    # 4 - Operation only valid for Standard Primary Zones
    # 5 - Secondary Zones cannot be DsIntegrated
    # 6 - Cannot convert Secondary, Stub or Forwarder to DsIntegrated
    Hidden [Void] ChangeZoneType(
        [ZoneType] $newZoneType,
        [Boolean]  $newDsIntegrated,
        [String]   $newDataFile,
        [String[]] $newIPAddressList
    ) {
        # Populate fields any null fields if possible

        if ([String]::IsNullOrWhiteSpace($this.DataFile)) {
            $newDataFile = '{0}.dns' -f $this.ZoneName
        } else {
            $newDataFile = $this.DataFile
        }

        if ($newZoneType -ne [ZoneType]::Primary -and [String]::IsNullOrWhiteSpace($newIPAddressList[0])) {
            if ($this.MasterServers.Count -gt 0) {
                $newIPAddressList = $this.MasterServers
            } elseif ($this.LocalMasterServers.Count -gt 0) {
                $newIPAddressList = $this.LocalMasterServers
            } else {
                $errorRecord = [ErrorRecord]::new(
                    [ArgumentException]::new('Unable to determine master server list and no list supplied'),
                    'InvalidMasterServerList',
                    'InvalidArgument',
                    $null
                )
                throw $errorRecord
            }
        }

        # Scenarios that will error when changing to Primary

        if ($newZoneType -eq 'Primary') {
            switch ($null) {
                { $this.ZoneType -in 'Stub', 'Forwarder' }             { throw 'InvalidExistingZoneType' }
                { $this.ZoneType -eq 'Secondary' -and $this.Shutdown } { throw 'CannotConvertShutdownZone' }
                { $this.ZoneType -eq 'Primary' -and $newDsIntegrated } { throw 'CannotConvertDSIntegratedZone' }
            }
        }

        # Scenarios that will error when changing to Secondary

        if ($newZoneType -eq 'Secondary' -and $newDsIntegrated) {
            throw 'SecondaryZonesCannotBeDsIntegrated'
        }

        # Scenarios that will error when changing to Stub and Forwarder

        if ($this.ZoneType -ne 'Primary' -and $newDsIntegrated -and -not $this.DsIntegrated) {
            throw 'CannotConvertToDsIntegrated'
        }

        $params = @{
            MethodName = 'ChangeZoneType'
            Arguments  = @{
                DataFileName = $newDataFile
                DsIntegrated = $newDsIntegrated
                IpAddr       = $newIPAddressList
                Zonetype     = [UInt32]$newZoneType - 1
            }
        }
        # Work on this
        $return = $this.CimInstance | Invoke-CimMethod @params
    }

    [Void] ForceRefresh() {
        $this.CimInstance | Invoke-CimMethod -MethodName 'ForceRefresh'
    }

    [Void] PauseZone() {
        # Work on this
        $this.CimInstance | Invoke-CimMethod 'PauseZone'
        $this.Paused = $true
    }

    [Void] ReloadZone() {
        $this.CimInstance | Invoke-CimMethod 'ReloadZone'
    }

    [Void] ResumeZone() {
        # Work on this
        $this.CimInstance | Invoke-CimMethod 'ResumeZone'
        $this.Paused = $false
    }

    [Void] SetZoneTransfer(
        [ZoneTransfer] $newZoneTransferSetting,
        [String[]]     $newSecondaryServers,
        [Notify]       $newNotifySetting,
        [String[]]     $newNotifyServers
    ) {
        if ($this.ZoneType -notin 'Primary', 'Secondary') {
            throw 'InvalidZoneType'
        }

        $params = @{
            MethodName = 'ResetSecondaries'
            Arguments  = @{
                SecureSecondaries = [UInt32]$newZoneTransferSetting
                Notify            = [UInt32]$newNotifySetting
            }
        }
        if ($newSecondaryServers) {
            $params.Arguments.Add('SecondaryServers', $newSecondaryServers)
        }
        if ($newNotifyServers) {
            $params.Arguments.Add('NotifyServers', $newNotifyServers)
        }
        # Work on this
        $this.CimInstance | Invoke-CimMethod @params
    }

    [Void] UpdateFromDS() {
        if ($this.DsIntegrated) {
            $this.CimInstance | Invoke-CimMethod 'UpdateFromDS'
        } else {
            'InvalidOperation'
        }
    }

    [Void] WriteBackZone() {
        $this.CimInstance | Invoke-CimMethod 'WriteBackZone'
    }
}