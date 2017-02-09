using System;

namespace Indented
{
    public static class EndianBitConverter
    {
        public static byte[] GetBytes(ushort value, bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                byte[] bytes = BitConverter.GetBytes(value);
                Array.Reverse(bytes);

                return bytes;
            }
            return BitConverter.GetBytes(value);
        }

        public static byte[] GetBytes(uint value, bool IsBigEndian)
        {
            if (IsBigEndian)
            {
                byte[] bytes = BitConverter.GetBytes(value);
                Array.Reverse(bytes);

                return bytes
            }
            return BitConverter.GetBytes(value);
        }

        public static string ToString(byte[] bytes)
        {
            return BitConverter.ToString(bytes).Replace("-", "")
        }
    }
}