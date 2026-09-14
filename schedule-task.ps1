param (
    [Parameter(Mandatory)]
    [string]$TaskName,

    [Parameter(Mandatory)]
    [string]$ScriptPath,

    [string]$ScriptArguments = "",

    [bool]$AtStartup = $true,

    [ValidateRange(0, [int]::MaxValue)]
    [int]$IntervalMinutes = 0
)

# Validate script path
if (-not (Test-Path $ScriptPath)) {
    Write-Error "Script path '$ScriptPath' does not exist."
    exit 1
}

# Resolve full path
$ResolvedScriptPath = (Resolve-Path $ScriptPath).Path
$ScheduledScriptPath = Join-Path -Path "C:\" -ChildPath (Split-Path -Path $ResolvedScriptPath -Leaf)

try {
    Copy-Item -Path $ResolvedScriptPath -Destination $ScheduledScriptPath -Force
} catch {
    Write-Error "Failed to copy script '$ResolvedScriptPath' to '$ScheduledScriptPath': $_"
    exit 1
}

# Compose full argument string for powershell.exe
$FullArguments = "-NoProfile -ExecutionPolicy Bypass -File `"$ScheduledScriptPath`""
if ($ScriptArguments) {
    $FullArguments += " $ScriptArguments"
}

# Define task action
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $FullArguments

# Define task triggers
$Triggers = @()
if ($AtStartup) {
    $Triggers += New-ScheduledTaskTrigger -AtStartup
}

if ($IntervalMinutes -gt 0) {
    # An omitted repetition duration means repeat indefinitely in the Task Scheduler schema.
    $Triggers += New-ScheduledTaskTrigger `
        -Once `
        -At (Get-Date) `
        -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes)
}

if ($Triggers.Count -eq 0) {
    Write-Error "Specify -AtStartup `$true or an -IntervalMinutes value greater than zero."
    exit 1
}

# Define task principal (run with highest privileges)
$Principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Register or overwrite the task
try {
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Triggers -Principal $Principal -Force
    Write-Host "Scheduled task '$TaskName' registered (or updated) to run '$ScheduledScriptPath'."
} catch {
    Write-Error "Failed to register scheduled task: $_"
}
