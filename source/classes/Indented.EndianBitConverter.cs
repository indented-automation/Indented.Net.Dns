using System;
using System.Text;

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

                return bytes;
            }
            return BitConverter.GetBytes(value);
        }

        public static string ToBinary(byte[] bytes)
        {
            StringBuilder binaryString = new StringBuilder();
            foreach (Byte byte in bytes) {
                binaryString.Append(Convert.ToString(byte, 2).PadLeft(8, "0"))
            }
            return binaryString.ToString();
        }

        public static string ToString(byte[] bytes)
        {
            return BitConverter.ToString(bytes).Replace("-", "");
        }
    }
}