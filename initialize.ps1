param (
    [string]$Username,
    [string]$CertificateCommonName = $null,
    [boolean]$AssignSslCertificatePermissionsAtStartup = $true,
    [int]$AssignSslCertificatePermissionsIntervalMinutes = 0
)

.\apply-telemetry-settings.ps1
.\configure-msedge.ps1
.\initialize-vm-temporary-storage.ps1
.\disable-server-manager-autostart.ps1
.\remove-arc-setup-prompt.ps1
.\download-and-install-dotnet.ps1
.\set-password-never-expires.ps1 -Username $Username

$hasTaskScheduler = Test-Path ".\schedule-task.ps1"

if ($CertificateCommonName) {
    .\assign-ssl-certificate-permissions.ps1 -CertificateCommonName $CertificateCommonName
    if ($hasTaskScheduler) {
        .\schedule-task.ps1 -TaskName "AssignSSLCertificatePermissions" -ScriptPath ".\assign-ssl-certificate-permissions.ps1" -ScriptArguments "-CertificateCommonName `"$CertificateCommonName`"" -AtStartup $AssignSslCertificatePermissionsAtStartup -IntervalMinutes $AssignSslCertificatePermissionsIntervalMinutes
    }
}

if ($hasTaskScheduler) {
    .\schedule-task.ps1 -TaskName "InitializeStorage" -ScriptPath ".\initialize-vm-temporary-storage.ps1"
}