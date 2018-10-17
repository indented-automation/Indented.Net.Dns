class DnsConditionalForwarder {
    this.ForwarderUseRecursion = (Boolean)wmiZone.Properties["ForwarderSlave"].Value;
    this.ForwarderTimeOut = (UInt32)wmiZone.Properties["ForwarderTimeOut"].Value;

    public String GetDistinguishedName()
    {
        return (String)this.wmiZone.InvokeMethod("GetDistinguishedName", new object[] { });
    }

}