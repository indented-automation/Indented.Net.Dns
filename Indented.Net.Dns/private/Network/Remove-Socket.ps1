using namespace System.Net.Sockets

function Remove-Socket {
    <#
    .SYNOPSIS
        Removes a socket, releasing all resources.
    .DESCRIPTION
        A socket may be removed using Remove-Socket if it is no longer required.
    .EXAMPLE
        PS> $Socket = New-Socket
        PS> $Socket | Connect-Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
        PS> $Socket | Disconnect-Socket
        PS> $Socket | Remove-Socket
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        # A socket created using New-Socket.
        [Parameter(Mandatory, ValueFromPipeline)]
        [Socket]$Socket
    )

    process {
        if ($pscmdlet.ShouldProcess('Closing socket')) {
            $Socket.Close()
        }
    }
}