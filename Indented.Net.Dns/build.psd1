@{
    ModuleManifest           = "Indented.Net.Dns.psd1"
    OutputDirectory          = "../build"
    VersionedOutputDirectory = $true
    SourceDirectories        = @(
        'Enum'
        'Class'
        'Private'
        'Public'
    )
    CopyPaths                = @(
        'var'
    )
    Suffix                   = @(
        'InitializeModule.ps1'
    )
}
