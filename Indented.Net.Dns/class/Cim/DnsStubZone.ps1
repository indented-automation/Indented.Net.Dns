if ((UInt32)wmiZone.Properties["LastSuccessfulSoaCheck"].Value != 0)
{
    this.LastSuccessfulSoaCheck = new DateTime(1970, 01, 01).AddSeconds(
       (UInt32)wmiZone.Properties["LastSuccessfulSoaCheck"].Value);
}

if ((UInt32)wmiZone.Properties["LastSuccessfulXfr"].Value != 0)
{
    this.LastSuccessfulXfr = new DateTime(1970, 01, 01).AddSeconds(
        (UInt32)wmiZone.Properties["LastSuccessfulXfr"].Value);
}

this.MasterServers = (String[])wmiZone.Properties["MasterServers"].Value;
this.LocalMasterServers = (String[])wmiZone.Properties["LocalMasterServers"].Value;