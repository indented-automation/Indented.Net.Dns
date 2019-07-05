Get-Process named -ErrorAction SilentlyContinue | Stop-Process

Split-Path $psscriptroot -Parent | Join-Path -ChildPath 'Data' | Push-Location

Remove-Item K*.key, K*.private, managed-key*, *.jbk, *.signed*, *.jnl

Pop-Location