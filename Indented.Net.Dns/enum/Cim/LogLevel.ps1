if (-not ('LogLevel' -as [Type])) {
    Add-Type '
        public enum LogLevel : uint {
            None         = 0,
            Query        = 1,
            Notify       = 16,
            Update       = 32,
            NonQuery     = 254,
            Questions    = 256,
            Answers      = 512,
            Send         = 4096,
            Receive      = 8192,
            Udp          = 16384,
            Tcp          = 32768,
            AllPackets   = 65535,
            DSWrite      = 65536,
            DSUpdate     = 131072,
            FullPackets  = 16777216,
            WriteThrough = 2147483648
        }
    '
}