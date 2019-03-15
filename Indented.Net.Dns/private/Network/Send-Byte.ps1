using namespace System.Management.Automation
using namespace System.Net
using namespace System.Net.Sockets

function Send-Byte {
    <#
    .SYNOPSIS
        Sends bytes using a TCP or UDP socket.
    .DESCRIPTION
        Send-Byte is used to send outbound TCP or UDP packets as a server responding to a cilent, or as a client sending to a server.
    .EXAMPLE
        PS>$Socket = New-Socket
        PS>Connect-Socket $Socket -RemoteIPAddress 10.0.0.1 -RemotePort 25
        PS>Send-Byte $Socket -Data 0
    .EXAMPLE
        PS>$Socket = New-Socket -ProtocolType Udp -EnableBroadcast
        PS>Send-Byte $Socket -Data 0
    #>

    [CmdletBinding(DefaultParameterSetName = 'DirectedTcpSend')]
    [OutputType([Void])]
    param (
        # A socket created using New-Socket. If the ProtocolType is TCP the socket must be connected first.
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [Socket]$Socket,

        # If the protocol type is UDP a remote IP address must be specified. Directed or undirected broadcast addresses may be used if EnableBroadcast has been set on the socket.
        [Parameter(Mandatory, ParameterSetName = 'DirectedUdpSend')]
        [IPAddress]$RemoteIPAddress,

        # Sets the RemoteIPAddress to the undirected broadcast address.
        [Parameter(Mandatory, ParameterSetName = 'BroadcastUdpSend')]
        [Switch]$Broadcast,

        # If the protocol type is UDP, a remote port must be specified.
        [Parameter(Mandatory, ParameterSetname = 'DirectedUdpSend')]
        [Parameter(Mandatory, ParameterSetName = 'BroadcastUdpSend')]
        [UInt16]$RemotePort,

        # The data to send (as a byte array).
        [Parameter(Mandatory)]
        [Byte[]]$Data
    )

    # Broadcast parameter set checking
    if ($pscmdlet.ParameterSetName -eq 'BroadcastUdpSend') {
        # IPv6 error checking
        if ($Socket.AddressFamily -eq [AddressFamily]::InterNetworkv6) {
            $errorRecord = [ErrorRecord]::new(
                [ArgumentException]::new('EnableBroadcast cannot be set for IPv6 sockets.'),
                'InvalidIPv6SocketState',
                [ErrorCategory]::InvalidArgument,
                $Socket
            )
        }

        # TCP socket error checking
        if (-not $Socket.ProtocolType) {
            $errorRecord = [ErrorRecord]::new(
                [ArgumentException]::new('EnableBroadcast cannot be set for TCP sockets.'),
                'InvalidTCPSocketState',
                [ErrorCategory]::InvalidArgument,
                $Socket
            )
        }

        # Broadcast flag checking
        if (-not $Socket.EnableBroadcast) {
            $errorRecord = [ErrorRecord]::new(
                [InvalidOperationException]::new('EnableBroadcast is not set on the socket.'),
                'BroadcastNotEnabled',
                [ErrorCategory]::InvalidOperation,
                $Socket
            )
        }
        if ($errorRecord) {
            $pscmdlet.ThrowTerminatingError($errorRecord)
        }

        $RemoteIPAddress = [IPAddress]::Broadcast
    }

    switch ($Socket.ProtocolType) {
        ([ProtocolType]::Tcp) {
            $null = $Socket.Send($Data)
        }
        ([ProtocolType]::Udp) {
            $remoteEndPoint = [EndPoint][IPEndPoint]::new($RemoteIPAddress, $RemotePort)

            $null = $Socket.SendTo($Data, $RemoteEndPoint)
        }
    }
}