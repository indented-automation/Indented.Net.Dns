using namespace System.Net.Sockets

function Disconnect-Socket {
    <#
    .SYNOPSIS
        Disconnect a connected TCP socket.
    .DESCRIPTION
        A TCP socket which has been connected using Connect-Socket may be disconnected using this CmdLet.
    .EXAMPLE
        PS> $Socket = New-Socket
        PS> $Socket | Connect-Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
        PS> $Socket | Disconnect-Socket
    #>

    [CmdletBinding()]
    param (
        # A socket created using New-Socket and connected using Connect-Socket.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [Socket]$Socket,

        # By default, Disconnect-Socket attempts to shutdown the connection before disconnecting. This behaviour can be overridden by setting this parameter to False.
        [Boolean]$Shutdown = $true
    )

    process {
        if ($Socket.ProtocolType -ne [ProtocolType]::Tcp) {
            $params = @{
                Exception = New-Object InvalidOperationException('The protocol type must be TCP to use Disconnect-Socket.')
                ErrorId   = 'InvalidProtocol'
                Category  = 'InvalidOperation'
            }
            Write-Error @params
        } else {
            if (-not $Socket.Connected) {
                Write-Warning 'The socket is not connected. No action taken.'
            } else {
                Write-Verbose ('Disconnected socket from {0}.' -f $Socket.RemoteEndPoint)

                if ($Shutdown) {
                    $Socket.Shutdown([SocketShutdown]::Both)
                }

                # Disconnect the socket and allow reuse.
                $Socket.Disconnect($true)
            }
        }
    }
}