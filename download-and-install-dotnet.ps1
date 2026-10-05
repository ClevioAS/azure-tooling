# The install script should be downloaded by the CustomScriptExtension on the VM ScaleSet
.\dotnet-install.ps1 -Runtime dotnet -Channel 8.0 -Quality GA -InstallDir "C:\Program Files\dotnet"
.\dotnet-install.ps1 -Runtime aspnetcore -Channel 8.0 -Quality GA -InstallDir "C:\Program Files\dotnet"
.\dotnet-install.ps1 -Runtime dotnet -Channel 9.0 -Quality GA -InstallDir "C:\Program Files\dotnet"
.\dotnet-install.ps1 -Runtime aspnetcore -Channel 9.0 -Quality GA -InstallDir "C:\Program Files\dotnet"
.\dotnet-install.ps1 -Runtime dotnet -Channel 10.0 -Quality GA -InstallDir "C:\Program Files\dotnet"
.\dotnet-install.ps1 -Runtime aspnetcore -Channel 10.0 -Quality GA -InstallDir "C:\Program Files\dotnet"

# Ensure the dotnet installation directory is in the system PATH
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\dotnet", [System.EnvironmentVariableTarget]::Machine)
