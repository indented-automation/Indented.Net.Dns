Get-Process named -ErrorAction SilentlyContinue | Stop-Process

Join-Path $PSScriptRoot -ChildPath '..\data\*' |
    Get-ChildItem -Include managed-key*, *.jbk, *.signed*, *.jnl, *.dns |
    Remove-Item
