using namespace System.Net
using namespace System.Net.Sockets

function Receive-Byte {
    <#
    .SYNOPSIS
        Receive bytes using a TCP or UDP socket.
    .DESCRIPTION
        Receive-Bytes is used to accept inbound TCP or UDP packets as a client exepcting a response from a server, or as a server waiting for incoming connections.

        Receive-Bytes will listen for bytes sent to broadcast addresses provided the socket has been created using EnableBroadcast.
    .INPUTS
        System.Net.Sockets.Socket
    .EXAMPLE
        PS> $Socket = New-Socket
        PS> Connect-Socket $Socket -RemoteIPAddress 10.0.0.1 -RemotePort 25
        PS> $Bytes = Receive-Bytes $Socket
        PS> $Bytes | ConvertTo-String
    .EXAMPLE
        PS> $Socket = New-Socket -ProtocolType Udp -EnableBroadcast
        PS> $Socket | Receive-Bytes
    #>

    [CmdletBinding()]
    [OutputType('Indented.Net.Sockets.SocketResponse')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        # A socket created using New-Socket. If the ProtocolType is TCP the socket must be connected first.
        [Socket]$Socket,

        # The maximum buffer size used for each receive operation.
        [UInt32]$BufferSize = 1024
    )

    $buffer = [Byte[]]::new($BufferSize)

    switch ($Socket.ProtocolType) {
        ([Net.Sockets.ProtocolType]::Tcp) {
            $bytesReceived = $Socket.Receive($buffer)
            # Maybe
            $remoteEndPoint = $Socket.RemoteEndPoint.Clone()
        }
        ([Net.Sockets.ProtocolType]::Udp) {
            # Create an IPEndPoint to use as a reference object
            if ($Socket.AddressFamily -eq [AddressFamily]::InterNetwork) {
                $remoteEndPoint = [EndPoint][IPEndPoint]::new([IPAddress]::Any, 0)
            } elseif ($Socket.AddressFamily -eq [AddressFamily]::InterNetworkv6) {
                $remoteEndPoint = [EndPoint][IPEndPoint]::new([IPAddress]::IPv6Any, 0)
            }

            $bytesReceived = $Socket.ReceiveFrom($buffer, [Ref]$remoteEndPoint)
        }
    }
    if ($bytesReceived) {
        Write-Verbose ('Receive-Bytes: Received {0} bytes from {1}' -f $bytesReceived, $remoteEndPoint)

        [PSCustomObject]@{
            BytesReceived  = $bytesReceived
            Data           = $buffer[0..$($bytesReceived - 1)]
            RemoteEndpoint = $remoteEndPoint
            PSTypeName     = 'Indented.Net.Sockets.SocketResponse'
        }
    }
}