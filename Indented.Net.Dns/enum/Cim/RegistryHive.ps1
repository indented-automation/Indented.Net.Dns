if (-not ('RegistryHive' -as [Type])) {
    Add-Type '
        public enum RegistryHive : uint {
            HKCR = 2147483628,    // HKEY_CLASSES_ROOT
            HKCU = 2147483649,    // HKEY_CURRENT_USER
            HKLM = 2147483650,    // HKEY_LOCAL_MACHINE
            HKU  = 2147483651,    // HKEY_USERS
            HKCC = 2147483653     // HKEY_CURRENT_CONFIG
        }
    '
}