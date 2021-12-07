# Resolver (Message): Initialize the DNS cache for Get-Dns
Initialize-InternalDnsCache

# Resolver (Message): Set a variable to store TC state.
New-Variable DnsTCEndFound -Scope Script -Value $false
