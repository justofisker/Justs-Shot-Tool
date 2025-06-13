$ErrorActionPreference = "Stop"

function New-TemporaryDirectory {
    $tmp = [System.IO.Path]::GetTempPath() # Not $env:TEMP, see https://stackoverflow.com/a/946017
    $name = (New-Guid).ToString("N")
    New-Item -ItemType Directory -Path (Join-Path $tmp $name)
}

$TARGET_WEB = "justofisker/rotmg-shot-tool:html5"
$TARGET_WINDOWS = "justofisker/rotmg-shot-tool:windows"
$TARGET_WINDOWS_ARM = "justofisker/rotmg-shot-tool:windows-arm"
$TARGET_LINUX = "justofisker/rotmg-shot-tool:linux"
$TARGET_LINUX_ARM = "justofisker/rotmg-shot-tool:linux-arm"

# Web Build
$WEB_BUILD_DIR = New-TemporaryDirectory
& $env:GODOT_BIN --headless --export-release "Web" "$($WEB_BUILD_DIR.FullName)\index.html" | Out-Host
butler push "$($WEB_BUILD_DIR.FullName)" "$TARGET_WEB"
Remove-Item -Recurse -Force $WEB_BUILD_DIR

# Windows Build
$WINDOWS_BUILD_DIR = New-TemporaryDirectory
& $env:GODOT_BIN --headless --export-release "Windows Desktop" "$($WINDOWS_BUILD_DIR.FullName)\Just's Shot Tool.exe" | Out-Host
Copy-Item -Recurse -Force assets "$($WINDOWS_BUILD_DIR.FullName)\assets"
Get-ChildItem -Path "$($WINDOWS_BUILD_DIR.FullName)\assets" -Recurse -Filter *.import | Remove-Item -Force
Copy-Item -Recurse -Force scripts "$($WINDOWS_BUILD_DIR.FullName)\scripts"
Get-ChildItem -Path "$($WINDOWS_BUILD_DIR.FullName)\scripts" -Recurse -Filter *.uid | Remove-Item -Force
New-Item -ItemType Directory -Path "$($WINDOWS_BUILD_DIR.FullName)\scenes" | Out-Null
butler push "$($WINDOWS_BUILD_DIR.FullName)" "$TARGET_WINDOWS"
Remove-Item -Recurse -Force $WINDOWS_BUILD_DIR

# Windows Arm Build
$WINDOWS_ARM_BUILD_DIR = New-TemporaryDirectory
& $env:GODOT_BIN --headless --export-release "Windows Arm Desktop" "$($WINDOWS_ARM_BUILD_DIR.FullName)\Just's Shot Tool.exe" | Out-Host
Copy-Item -Recurse -Force assets "$($WINDOWS_ARM_BUILD_DIR.FullName)\assets"
Get-ChildItem -Path "$($WINDOWS_ARM_BUILD_DIR.FullName)\assets" -Recurse -Filter *.import | Remove-Item -Force
Copy-Item -Recurse -Force scripts "$($WINDOWS_ARM_BUILD_DIR.FullName)\scripts"
Get-ChildItem -Path "$($WINDOWS_ARM_BUILD_DIR.FullName)\scripts" -Recurse -Filter *.uid | Remove-Item -Force
New-Item -ItemType Directory -Path "$($WINDOWS_ARM_BUILD_DIR.FullName)\scenes" | Out-Null
butler push "$($WINDOWS_ARM_BUILD_DIR.FullName)" "$TARGET_WINDOWS_ARM"
Remove-Item -Recurse -Force $WINDOWS_ARM_BUILD_DIR

# Linux Build
$LINUX_BUILD_DIR = New-TemporaryDirectory
& $env:GODOT_BIN --headless --export-release "Linux" "$($LINUX_BUILD_DIR.FullName)\Just's Shot Tool" | Out-Host
Copy-Item -Recurse -Force assets "$($LINUX_BUILD_DIR.FullName)\assets"
Get-ChildItem -Path "$($LINUX_BUILD_DIR.FullName)\assets" -Recurse -Filter *.import | Remove-Item -Force
Copy-Item -Recurse -Force scripts "$($LINUX_BUILD_DIR.FullName)\scripts"
Get-ChildItem -Path "$($LINUX_BUILD_DIR.FullName)\scripts" -Recurse -Filter *.uid | Remove-Item -Force
New-Item -ItemType Directory -Path "$($LINUX_BUILD_DIR.FullName)\scenes" | Out-Null
butler push "$($LINUX_BUILD_DIR.FullName)" "$TARGET_LINUX"
Remove-Item -Recurse -Force $LINUX_BUILD_DIR

# Linux Arm Build
$LINUX_ARM_BUILD_DIR = New-TemporaryDirectory
& $env:GODOT_BIN --headless --export-release "Linux Arm" "$($LINUX_ARM_BUILD_DIR.FullName)\Just's Shot Tool" | Out-Host
Copy-Item -Recurse -Force assets "$($LINUX_ARM_BUILD_DIR.FullName)\assets"
Get-ChildItem -Path "$($LINUX_ARM_BUILD_DIR.FullName)\assets" -Recurse -Filter *.import | Remove-Item -Force
Copy-Item -Recurse -Force scripts "$($LINUX_ARM_BUILD_DIR.FullName)\scripts"
Get-ChildItem -Path "$($LINUX_ARM_BUILD_DIR.FullName)\scripts" -Recurse -Filter *.uid | Remove-Item -Force
New-Item -ItemType Directory -Path "$($LINUX_ARM_BUILD_DIR.FullName)\scenes" | Out-Null
butler push "$($LINUX_ARM_BUILD_DIR.FullName)" "$TARGET_LINUX_ARM"
Remove-Item -Recurse -Force $LINUX_ARM_BUILD_DIR
