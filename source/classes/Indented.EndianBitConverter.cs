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
    }
}