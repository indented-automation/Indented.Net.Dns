using System;
using System.IO;
using System.Net;

namespace Indented.IO
{
    ///<summary>
    ///A binary reader capable of reading byte streams with consideration for Endian o
    ///</summary>
    public class EndianBinaryReader : BinaryReader
    {
        long marker = 0;

        public EndianBinaryReader(Stream BaseStream) : base(BaseStream) { }

        public long Marker
        {
            get { return marker; }
        }

        public long MarkerOffset
        {
            get { return BaseStream.Position - marker; }
        }

        public void SetMarker()
        {
            marker = BaseStream.Position;
        }

        public byte PeekByte()
        {
            Byte value = base.ReadByte();
            base.BaseStream.Seek(-1, System.IO.SeekOrigin.Current);
            return value;
        }   

        public short ReadInt16(bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                Byte[] array = ReadBytes(2);
                return (short)(
                    array[1] |
                    (array[0] << 8) );
            }
            return ReadInt16();
        }

        public ushort ReadUInt16(bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                Byte[] array = ReadBytes(2);
                return (ushort) (
                    array[1] |
                    (array[0] << 8) );
            }
            return ReadUInt16();
        }

        public int ReadInt32(bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                Byte[] array = ReadBytes(4);
                return (int) (
                    array[3] |
                    (array[2] << 8) |
                    (array[1] << 16) |
                    (array[0] << 24) );
            }
            return ReadInt32();
        }

        public uint ReadUInt32(bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                Byte[] array = ReadBytes(4);
                return (uint) (
                    array[3] |
                    (array[2] << 8) |
                    (array[1] << 16) |
                    (array[0] << 24) );
            }
            return ReadUInt32();
        }

        public ulong ReadUInt48()
        {
            Byte[] array = ReadBytes(6);
            ulong lowOrder = (ulong) (
                array[0] |
                (array[1] << 8) |
                (array[2] << 16) |
                (array[3] << 24) );
            ulong highOrder = (ulong) (
                array[4] |
                (array[5] << 40) );
            return lowOrder | (highOrder << 32);
        }

        public ulong ReadUInt48(bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                Byte[] array = ReadBytes(6);
                ulong lowOrder = (ulong) (
                    array[5] |
                    (array[4] << 8) |
                    (array[3] << 16) |
                    (array[2] << 24) );
                ulong highOrder = (ulong) (
                    array[1] |
                    (array[0] << 8) );
                return lowOrder | (highOrder << 32);
            }
            return ReadUInt48();
        }

        public long ReadInt64(bool IsBigEndian)
        {
            if (IsBigEndian)
            {

                Byte[] array = ReadBytes(8);
                long lowOrder = (long) (
                    array[7] |
                    (array[6] << 8) |
                    (array[5] << 16) |
                    (array[4] << 24) );
                long highOrder = (long) (
                    array[3] |
                    (array[2] << 8) |
                    (array[1] << 16) |
                    (array[0] << 24) );
                return lowOrder | (highOrder << 32);
            }
            return ReadInt64();
        }

        public ulong ReadUInt64(bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                Byte[] array = ReadBytes(8);
                ulong lowOrder = (ulong) (
                    array[7] |
                    (array[6] << 8) |
                    (array[5] << 16) |
                    (array[4] << 24) );
                ulong highOrder = (ulong) (
                    array[3] |
                    (array[2] << 8) |
                    (array[1] << 16) |
                    (array[0] << 24) );
                return lowOrder | (highOrder << 32);
            }
            return ReadUInt64();
        }

        public IPAddress ReadIPAddress()
        {
            return new IPAddress(ReadBytes(4));
        }

        public IPAddress ReadIPAddress(bool IPv6)
        {
            if (IPv6)
            {
                return new IPAddress(ReadBytes(16));
            }
            return ReadIPAddress();
        }
    }
}