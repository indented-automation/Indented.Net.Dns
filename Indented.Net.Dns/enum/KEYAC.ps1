enum KEYAC {
    AuthAndConfPermitted = 0    # Use of the key for authentication and/or confidentiality is permitted.
    AuthProhibited       = 2    # Use of the key is prohibited for authentication.
    ConfProhibited       = 1    # Use of the key is prohibited for confidentiality.
    NoKey                = 3    # No key information
}