function Update-InternalRootHints {
  # .SYNOPSIS
  #   Updates the root hints file from InterNIC then re-initializes the internal cache.
  # .DESCRIPTION
  #   The root hints file is used as the basis of an internal DNS cache. The content of the root hints file is used during iterative name resolution.
  # .PARAMETER Source
  #   Update-InternalRootHints attempts to download a named.root file from InterNIC by default. An alternative root hints source may be specified here.
  # .INPUTS
  #   System.String
  # .EXAMPLE
  #   Update-InternalRootHints
  # .NOTES
  #   Author: Chris Dent
  #
  #   Change log:
  #     13/01/2015 - Chris Dent - Forked from source module.
  
  [CmdLetBinding()]
  param(
    [URI]$Source = "http://www.internic.net/domain/named.root"
  )
  
  Get-WebContent $Source -FileName $psscriptroot\..\var\named.root
  Initialize-InternalDnsCache
}

