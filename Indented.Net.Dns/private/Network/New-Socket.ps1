using namespace System.Management.Automation
using namespace System.Net
using namespace System.Net.Sockets

function New-Socket {
    # .SYNOPSIS
    #   Creates a new network socket to use to send and receive packets over a network.
    # .DESCRIPTION
    #   New-Socket creates an instance of System.Net.Sockets.Socket for use with Send-Bytes and Receive-Bytes.
    # .EXAMPLE
    #   New-Socket -LocalPort 25
    #
    #   Configure a socket to listen using TCP/25 (as a network server) on all locally configured IP addresses.
    # .EXAMPLE
    #   New-Socket -ProtocolType Udp
    #
    #   Configure a socket for sending UDP datagrams (as a network client).
    # .EXAMPLE
    #   New-Socket -LocalPort 23 -LocalIPAddress 10.0.0.1
    #
    #   Configure a socket to listen using TCP/23 (as a network server) on the IP address 10.0.0.1 (the IP address must exist and be bound to an interface).
    # .NOTES
    #   Change log:
    #     17/03/2017 - Chris Dent - Modernisation pass.
    #     25/11/2010 - Chris Dent - Created.

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding(DefaultParameterSetName = 'ClientSocket')]
    [OutputType([System.Net.Sockets.Socket])]
    param(
        # ProtocolType must be either TCP or UDP. This parameter also sets the SocketType to Stream for TCP and Datagram for UDP.
        [ValidateSet('Tcp', 'Udp')]
        [ProtocolType]$ProtocolType = 'Tcp',

        # If configuring a server port (to listen for requests) an IP address may be defined. By default the Socket is created to listen on all available addresses.
        [Parameter(ParameterSetName = 'ServerSocket')]
        [IPAddress]$LocalIPAddress = [IPAddress]::Any,

        # If configuring a server port (to listen for requests) the local port number must be defined.
        [Parameter(Mandatory = $true, ParameterSetName = 'ServerSocket')]
        [UInt16]$LocalPort,

        # Allows a UDP socket to send and receive datagrams from the directed or undirected broadcast IP address.
        [Parameter(ParameterSetName = 'ClientSocket')]
        [Switch]$EnableBroadcast,

        # Use IPv6 as the transport.
        [Switch]$IPv6,

        # By default, send and receive timeout values are set for all operations. These values can be overridden to allow configuration of a socket which will never stop either attempting to send or attempting to receive.
        [Switch]$NoTimeout,

        # A timeout for individual Receive operations performed with this socket. The default value is 5 seconds; this command allows the value to be set between 1 and 30 seconds.
        [ValidateRange(1, 30)]
        [Int32]$ReceiveTimeOut = 5,

        # A timeout for individual Send operations performed with this socket. The default value is 5 seconds; this command allows the value to be set between 1 and 30 seconds.
        [ValidateRange(1, 30)]
        [Int32]$SendTimeOut = 5,

        # The number of 
        [Int32]$ListenBacklog = 0
    )

    $socketType = switch ($ProtocolType) {
        ([ProtocolType]::Tcp) { [SocketType]::Stream }
        ([ProtocolType]::Udp) { [SocketType]::Dgram } 
    }

    $addressFamily = [AddressFamily]::InterNetwork

    if ($IPv6) {
        $addressFamily = [AddressFamily]::Internetworkv6
        # If LocalIPAddress has not been explicitly defined, and IPv6 is expected, change to all IPv6 addresses.
        if ($LocalIPAddress -eq [IPAddress]::Any) {
            $LocalIPAddress = [IPAddress]::IPv6Any
        }
    }

    $socket = New-Object Socket(
        $addressFamily,
        $SocketType,
        $ProtocolType
    )

    if ($EnableBroadcast) {
        if ($ProtocolType -eq [ProtocolType]::Udp) {
            $socket.EnableBroadcast = $true
        } else {
            $errorRecord = New-Object ErrorRecord(
                (New-Object ArgumentException('EnableBroadcast cannot be set for TCP sockets.')),
                'CannotSetEnableBroadcastForTcp',
                [ErrorCategory]::InvalidArgument,
                $ProtocolType
            )
            $pscmdlet.ThrowTerminatingError($errorRecord)
        }
    }

    # Bind a local end-point to listen for inbound requests.
    if ($pscmdlet.ParameterSetName -eq 'ServerSocket') {
        [EndPoint]$localEndPoint = New-Object IPEndPoint($LocalIPAddress, $LocalPort)
        $socket.Bind($LocalEndPoint)

        if ($ProtocolType -eq 'Tcp') {
            $socket.Listen($ListenBacklog)
        }
    }

    # Set timeout values if applicable.
    if (-not $NoTimeout) {
        $socket.SendTimeOut = $SendTimeOut * 1000
        $socket.ReceiveTimeOut = $ReceiveTimeOut * 1000
    }

    return $socket
}