class DnsPrimaryZone {


    # Aging and Scavenging

    this.Aging = (Boolean)wmiZone.Properties["Aging"].Value;
    this.DynamicUpdate = (ZoneDynamicUpdate)(UInt32)wmiZone.Properties["AllowUpdate"].Value;

    if ((UInt32)wmiZone.Properties["AvailForScavengeTime"].Value != 0)
    {
        this.AvailForScavengeTime = new DateTime(1601, 1, 1).AddHours(
            (UInt32)wmiZone.Properties["AvailForScavengeTime"].Value);
    }

    this.NoRefreshInterval = new TimeSpan((Int32)(UInt32)wmiZone.Properties["NoRefreshInterval"].Value, 0, 0);
    this.RefreshInterval = new TimeSpan((Int32)(UInt32)wmiZone.Properties["RefreshInterval"].Value, 0, 0);
    this.ScavengeServers = (String[])wmiZone.Properties["ScavengeServers"].Value;

    // Zone Transfers

    this.ZoneTransferSetting = (ZoneTransfer)(UInt32)wmiZone.Properties["SecureSecondaries"].Value;
    this.SecondaryServers = (String[])wmiZone.Properties["SecondaryServers"].Value;
    this.NotifySetting = (Notify)(UInt32)wmiZone.Properties["Notify"].Value;
    this.NotifyServers = (String[])wmiZone.Properties["NotifyServers"].Value;

    // WINS

    this.DisableWINSRecordReplication = false;
    if (wmiZone.Properties["DisableWINSRecordReplication"].Value != null)
    {
        this.DisableWINSRecordReplication = (Boolean)wmiZone.Properties["DisableWINSRecordReplication"].Value;
    }
    this.UseWins = (Boolean)wmiZone.Properties["UseWins"].Value;

    // Wrapper for AgeAllRecords Method
    //
    // This method call will fail if:
    //   NodeName is not fully-qualified or @
    //   NodeName does not exist

    internal UInt32 AgeAllRecords(String NodeName, Boolean ApplyToSubtree)
    {
        if (NodeName != "@" | !NodeName.Contains(this.ZoneName))
        {
            return 1;
        }

        return (UInt32)this.wmiZone.InvokeMethod("AgeAllRecords", new object[] { NodeName, ApplyToSubtree });
    }

    public String GetDistinguishedName()
    {
        return (String)this.wmiZone.InvokeMethod("GetDistinguishedName", new object[] { });
    }

}