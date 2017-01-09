using System;

namespace Indented.IO
{
    public class EndianBinaryReader : BinaryReader
    {
        int marker = 0;

        public int Marker
        {
            get { return marker; }
            set { marker = value; }
        }

        public int MarkerOffset
        {
            get { return BaseStream.Position - marker; }
        }

        public void SetMarker()
        {
            marker = BaseStream.Position;
        }

        public byte PeekByte()
        {
            if (BaseStream.Capacity > BaseStream.Position + 1)
            {
                byte value = ReadByte();
                BaseStream.Seek(-1, SeekOrigin.Current);
            }
            else
            {
                throw 'Cannot peek, at end of stream';
            }
            return value;
        }

        public UInt16 ReadBEUInt16()
        {
            Byte[] array = ReadBytes(2)
            Array.Reverse(array);
            return BitConverter.ToUInt16(array, 0);
        }

        public UInt32 ReadBEInt32()
        {
            Byte[] array = ReadBytes(4)
            Array.Reverse(array);
            return BitConverter.ToUInt32(array, 0);
        }

        public UInt64 ReadBEInt48()
        {
            Byte[] array = ReadBytes(4)
            Array.Reverse(array);
            return BitConverter.ToUInt32(array, 0);
        }
    }
}