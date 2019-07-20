using namespace System.Management.Automation

class TransformDnsName : ArgumentTransformationAttribute {
    [Object] Transform(
        [EngineIntrinsics] $engineIntrinsics,
        [Object]           $inputData
    ) {
        $name = $inputData.ToString()

        if ($name -eq '.') {
            return $name
        }

        try {
            return [System.Globalization.IdnMapping]::new().GetAscii($name)
        } catch {
            return $name
        }
    }
}