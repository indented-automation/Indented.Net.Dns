using namespace System.Net
using namespace System.Net.Sockets

function Connect-Socket {
    <#
    .SYNOPSIS
        Connect a TCP socket to a remote IP address and port.
    .DESCRIPTION
        If a TCP socket is being used as a network client it must first connect to a server before Send-Bytes and Receive-Bytes can be used.
    .EXAMPLE
        PS> $Socket = New-Socket
        PS> Connect-Socket $Socket -RemoteIPAddress 10.0.0.2 -RemotePort 25
    #>

    [CmdletBinding()]
    [OutputType([Boolean])]
    param (
        # A socket created using New-Socket.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [Socket]$Socket,

        # The remote IP address to connect to.
        [Parameter(Mandatory )]
        [Alias('IPAddress')]
        [IPAddress]$RemoteIPAddress,

        # The remote port to connect to.
        [Parameter(Mandatory)]
        [Alias('Port')]
        [UInt16]$RemotePort
    )

    process {
        if ($Socket.ProtocolType -ne [ProtocolType]::Tcp) {
            $params = @{
                Exception = [InvalidOperationException]::new('The protocol type must be TCP to use Connect-Socket.')
                ErrorId   = 'InvalidProtocol'
                Category  = 'InvalidOperation'
            }
            Write-Error @params
        } else {
            $remoteEndPoint = [EndPoint][IPEndPoint]::new($RemoteIPAddress, $RemotePort)

            if ($Socket.Connected) {
                Write-Verbose ('The socket is connected to {0}. No action taken.' -f $Socket.RemoteEndPoint)

                return $true
            } else {
                try {
                    $Socket.Connect($RemoteEndPoint)

                    return $true
                } catch {
                    Write-Error -ErrorRecord $_
                }
            }
        }
        return $false
    }
}