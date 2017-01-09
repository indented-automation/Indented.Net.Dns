function Add-InternalDnsCacheRecord {
  # .SYNOPSIS
  #   Add a new CacheRecord to the DNS cache object.
  # .DESCRIPTION
  #   Cache records must expose the following property members:
  #
  #    - Name
  #    - TTL
  #    - RecordType
  #    - IPAddress
  #
  # .PARAMETER CacheRecord
  #   A record to add to the cache.
  # .PARAMETER Permanent
  #   A time property is used to age entries out of the cache. If permanent is set the time is not, the value will not be purged based on the TTL.
  # .INPUTS
  #   Indented.DnsResolver.Message.CacheRecord
  # .EXAMPLE
  #   $CacheRecord | Add-InternalDnsCacheRecord
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     07/04/2015 - Chris Dent - BugFix: Type check for CacheRecord.
  #     13/01/2015 - Chris Dent - Forked from source module.
  
  [CmdLetBinding(DefaultParameterSetName = 'CacheRecord')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'CacheRecord')]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.CacheRecord' } )]
    $CacheRecord,
    
    [Parameter(Mandatory = $true, ParameterSetName = 'ResourceRecord')]
    [ValidateScript( { $_.PsObject.TypeNames -contains 'Indented.DnsResolver.Message.ResourceRecord' } )]
    $ResourceRecord,
    
    [ValidateSet("Address", "Hint")]
    [String]$ResourceType = "Address",
    
    [Switch]$Permanent
  )

  begin {
    if (-not $Permanent) {
      $Time = Get-Date
    }
  }

  process {
    if ($ResourceRecord) {
      $TempObject = $ResourceRecord | Select-Object Name, TTL, RecordType, IPAddress
      $TempObject.PsObject.TypeNames.Add('Indented.DnsResolver.Message.CacheRecord')
      $CacheRecord = $TempObject
    }
  
    $CacheRecord | Add-Member ResourceType -MemberType NoteProperty -Value $ResourceType
    $CacheRecord | Add-Member Time -MemberType NoteProperty -Value $Time
    $CacheRecord | Add-Member Status -MemberType ScriptProperty -Value {
      if ($this.Time) {
        if ($this.Time.AddSeconds($this.TTL) -lt (Get-Date)) {
          "Expired"
        } else {
          "Active"
        }
      } else {
        "Permanent"
      }
    }
  
    if ($DnsCache.Contains($CacheRecord.Name)) {
      # Add the record to the cache if it doesn't already exist.
      if (-not ($CacheRecord | Get-InternalDnsCacheRecord)) {
        $DnsCache[$CacheRecord.Name] += $CacheRecord
      }
    } else {
      $DnsCache.Add($CacheRecord.Name, @($CacheRecord))
      if (-not ($DnsCacheReverse.Contains($CacheRecord.IPAddress))) {
        $DnsCacheReverse.Add($CacheRecord.IPAddress, $CacheRecord.Name)
      }
    }
  }      
}