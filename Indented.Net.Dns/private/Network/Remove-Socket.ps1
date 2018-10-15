using namespace System.Net.Sockets

function Remove-Socket {
    # .SYNOPSIS
    #   Removes a socket, releasing all resources.
    # .DESCRIPTION
    #   A socket may be removed using Remove-Socket if it is no longer required.
    # .INPUTS
    #   System.Net.Sockets.Socket
    # .OUTPUTS
    #   None
    # .EXAMPLE
    #   C:\PS> $Socket = New-Socket
    #   C:\PS> $Socket | Connect-Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
    #   C:\PS> $Socket | Disconnect-Socket
    #   C:\PS> $Socket | Remove-Socket
    # .NOTES
    #   Author: Chris Dent
    #
    #   Change log:
    #     17/03/2017 - Chris Dent - Modernisation pass.
    #     25/11/2010 - Chris Dent - Created.

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    [OutputType([Void])]
    param(
        # A socket created using New-Socket.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Socket]$Socket
    )

    process {
        $Socket.Close()
    }
}