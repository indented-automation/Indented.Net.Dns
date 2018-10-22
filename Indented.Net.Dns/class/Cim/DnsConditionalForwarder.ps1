class DnsConditionalForwarder : DnsZone {
    [Boolean] $ForwarderUseRecursion
    [UInt32]  $ForwarderTimeOut

    Hidden [Void] UpdateProperties() {
        $this.ForwarderUseRecursion = $this.CimInstance.ForwarderSlave
        $this.ForwarderTimeOut = $this.CimInstance.ForwarderTimeOut
    }

    [String] GetDistinguishedName() {
        return $this.CimInstance | Invoke-CimMethod -MethodName 'GetDistinguishedName'
    }
}