using namespace System.Management.Automation

class ValidateDnsName : ValidateEnumeratedArgumentsAttribute {
    Hidden $nameRegex = '^([A-Z0-9]|_[A-Z])(([\w\-]{0,61})[^_\-])?(\.([A-Z0-9]|_[A-Z])(([\w\-]{0,61})[^_\-])?)*$|^\.$'

    ValidateDnsName() { }

    [Void] ValidateElement(
        [Object]$element
    ) {
        if (-not ([IPAddress]::TryParse($element, [Ref]$null)) -and $element -notmatch $this.nameRegex) {
            $errorRecord = [ErrorRecord]::new(
                [ArgumentException]::new('Invalid name format'),
                'InvalidDnsName',
                [ErrorCategory]::InvalidArgument,
                $element
            )
            throw $errorRecord
        }
    }
}