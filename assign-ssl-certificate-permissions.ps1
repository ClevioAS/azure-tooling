param (
    [string]$CertificateCommonName
)

Get-ChildItem Cert:\LocalMachine\My | Where-Object {
    $_.PrivateKey -and
    $_.Subject -like "*CN=$CertificateCommonName*"
} | ForEach-Object {
    $keyPath = "$env:ProgramData\Microsoft\Crypto\RSA\MachineKeys\$($_.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName)"
    if (Test-Path $keyPath) {
        $acl = Get-Acl $keyPath
        $networkServiceSid = New-Object System.Security.Principal.SecurityIdentifier(
            [System.Security.Principal.WellKnownSidType]::NetworkServiceSid,
            $null
        )
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            "NETWORK SERVICE", "Read", "Allow"
        )
        $hasReadAccess = $acl.Access | Where-Object {
            $_.IdentityReference.Translate([System.Security.Principal.SecurityIdentifier]).Value -eq $networkServiceSid.Value -and
            $_.AccessControlType -eq $rule.AccessControlType -and
            ($_.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Read) -ne 0
        }

        if ($hasReadAccess) {
            Write-Host "NETWORK SERVICE already has read access to key container: $($_.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName)"
        } else {
            $acl.AddAccessRule($rule)
            Set-Acl $keyPath $acl
            Write-Host "Granted read access to NETWORK SERVICE for key container: $($_.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName)"
        }
    } else {
        Write-Warning "Key path not found for certificate: $($_.Subject)"
    }
}

