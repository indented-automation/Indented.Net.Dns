using namespace System.Collections.Generic
using namespace System.Net
using namespace System.Net.Sockets

class DnsClient {
    [Int32]     $BufferSize = 4096
    [EndPoint]  $RemoteEndPoint
    [Timespan]  $TimeTaken

    hidden [Socket] $socket

    DnsClient() {
        $this.Initialize($false, 5, 5)
    }

    DnsClient(
        [Boolean] $UseTcp
    ) {
        $this.Initialize($useTcp, 5, 5)
    }

    DnsClient(
        [Boolean] $useTcp,
        [Int32]   $receiveTimeout,
        [Int32]   $sendTimeout
    ) {
        $this.Initialize($useTcp, $receiveTimeout, $sendTimeout)
    }

    [Void] Initialize(
        [Boolean] $useTcp,
        [Int32]   $receiveTimeout,
        [Int32]   $sendTimeout
    ) {
        if ($useTcp) {
            $this.Socket = [Socket]::new('Stream', 'Tcp')
        } else {
            $this.Socket = [Socket]::new('Dgram', 'Udp')
        }
        $this.Socket.ReceiveTimeout = $receiveTimeout
        $this.Socket.SendTimeout = $sendTimeout
    }

    [Void] SendQuestion(
        [DnsMessage] $message,
        [IPAddress]  $ipAddress
    ) {
        $this.SendQuestion(
            $message,
            $ipAddress,
            53
        )
    }

    [Void] SendQuestion(
        [DnsMessage] $message,
        [IPAddress]  $ipAddress,
        [UInt16]     $port
    ) {
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
    }

    [DnsMessage] ReceiveAnswer() {
        try {
            $buffer = [Byte[]]::new($this.bufferSize)

            if ($this.socket.ProtocolType -eq 'Tcp') {
                $bytesReceived = $this.socket.Receive($buffer)

                $length = [BitConverter]::ToUInt16(($buffer[1, 0]), 0)
                $messageBytes = [Byte[]]::new($length)
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
                        0,
                        $bytesReceived
                    )
                }

                $this.RemoteEndPoint = $this.socket.RemoteEndPoint
            } else {
                if ($this.socket.AddressFamily -eq 'InterNetwork') {
                    $this.RemoteEndPoint = [IPEndPoint]::new([IPAddress]::Any, 0)
                } else {
                    $this.RemoteEndPoint = [IPEndPoint]::new([IPAddress]::IPv6Any, 0)
                }

                $bytesReceived = $this.socket.ReceiveFrom($buffer, [Ref]$this.RemoteEndPoint)

                $messageBytes = [Byte[]]::new($bytesReceived)

                [Array]::Copy(
                    $buffer,
                    $messageBytes,
                    $bytesReceived
                )
            }

            return [DnsMessage]::new($messageBytes)
        } catch {
            throw
        }
    }

    [Void] Close() {
        if ($this.socket.ProtocolType -eq 'Tcp') {
            $this.socket.Shutdown([SocketShutdown]::Both)
            $this.socket.Disconnect($true)
        }
        $this.socket.Close()
    }
}