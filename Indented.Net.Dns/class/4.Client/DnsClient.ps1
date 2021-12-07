using namespace System.Collections.Generic
using namespace System.Diagnostics
using namespace System.Net
using namespace System.Net.Sockets

class DnsClient {
    [int]     $BufferSize = 4096
    [EndPoint]  $RemoteEndPoint
    [Timespan]  $TimeTaken

    hidden [Socket] $socket

    DnsClient() {
        $this.Initialize($false, $false, 5, 5)
    }

    DnsClient(
        [bool] $useTcp,
        [bool] $useIPv6
    ) {
        $this.Initialize($useTcp, $useIPv6, 5, 5)
    }

    DnsClient(
        [bool] $useTcp,
        [bool] $useIPv6,
        [int]   $receiveTimeout,
        [int]   $sendTimeout
    ) {
        $this.Initialize($useTcp, $useIPv6, $receiveTimeout, $sendTimeout)
    }

    hidden [void] Initialize(
        [bool] $useTcp,
        [bool] $useIPv6,
        [int]   $receiveTimeout,
        [int]   $sendTimeout
    ) {
        $addressFamily = 'InterNetwork'
        if ($useIPv6) {
            $addressFamily = 'InterNetworkV6'
        }
        if ($useTcp) {
            $this.Socket = [Socket]::new($addressFamily, 'Stream', 'Tcp')
        } else {
            $this.Socket = [Socket]::new($addressFamily, 'Dgram', 'Udp')
        }
        $this.Socket.ReceiveTimeout = $receiveTimeout * 1000
        $this.Socket.SendTimeout = $sendTimeout * 1000
    }

    [void] SendQuestion(
        [DnsMessage] $message,
        [IPAddress]  $ipAddress
    ) {
        $this.SendQuestion(
            $message,
            $ipAddress,
            53
        )
    }

    [void] SendQuestion(
        [DnsMessage] $message,
        [IPAddress]  $ipAddress,
        [ushort]     $port
    ) {
        try {
            $stopWatch = [StopWatch]::StartNew()

            $this.RemoteEndPoint = [EndPoint][IPEndPoint]::new($ipAddress, $port)

            if ($this.socket.ProtocolType -eq 'Tcp') {
                try {
                    $this.socket.Connect($this.RemoteEndPoint)
                    $this.socket.Send($message.ToByteArray($true, $true))
                } catch {
                    throw
                }
            } else {
                $null = $this.socket.SendTo(
                    $message.ToByteArray($false, $true),
                    $this.RemoteEndPoint
                )
            }
        } catch {
            throw
        } finally {
            $stopWatch.Stop()

            $this.TimeTaken = $stopWatch.Elapsed
        }
    }

    [DnsMessage] ReceiveAnswer() {
        return $this.ReceiveAnswer($true)
    }

    [DnsMessage] ReceiveAnswer(
        [bool] $convertIdnToUnicode
    ) {
        try {
            $stopWatch = [StopWatch]::StartNew()

            $messageBytes = $this.ReceiveBytes()

            return [DnsMessage]::new($messageBytes, $convertIdnToUnicode)
        } catch {
            throw
        } finally {
            $stopWatch.Stop()

            $this.TimeTaken += $stopWatch.Elapsed
        }
    }

    [byte[]] ReceiveBytes() {
        try {
            $buffer = [byte[]]::new($this.bufferSize)

            if ($this.socket.ProtocolType -eq 'Tcp') {
                $bytesReceived = $this.socket.Receive($buffer)
                $length = [BitConverter]::ToUInt16(($buffer[1, 0]), 0)
                $messageBytes = [byte[]]::new($length)
                [Array]::Copy(
                    $buffer,
                    2,
                    $messageBytes,
                    0,
                    $bytesReceived - 2
                )

                $totalBytesReceived = $bytesReceived

                while ($totalBytesReceived -lt $length) {
                    $bytesReceived = $this.socket.Receive($buffer)
                    [Array]::Copy(
                        $buffer,
                        0,
                        $messageBytes,
                        $totalBytesReceived - 2,
                        $bytesReceived
                    )
                    $totalBytesReceived += $bytesReceived
                }

                $this.RemoteEndPoint = $this.socket.RemoteEndPoint
            } else {
                if ($this.socket.AddressFamily -eq 'InterNetwork') {
                    $endPoint = [IPEndPoint]::new([IPAddress]::Any, 0)
                } else {
                    $endPoint = [IPEndPoint]::new([IPAddress]::IPv6Any, 0)
                }

                $bytesReceived = $this.socket.ReceiveFrom($buffer, [ref]$endPoint)
                $this.RemoteEndPoint = $endPoint

                $messageBytes = [byte[]]::new($bytesReceived)
                [Array]::Copy(
                    $buffer,
                    $messageBytes,
                    $bytesReceived
                )
            }

            return $messageBytes
        } catch {
            throw
        }
    }

    [void] Close() {
        if ($this.socket.ProtocolType -eq 'Tcp') {
            $this.socket.Shutdown([SocketShutdown]::Both)
            $this.socket.Disconnect($true)
        }
        $this.socket.Close()
    }
}
