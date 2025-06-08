$ErrorActionPreference = "Stop"

$TARGET_WEB = "justofisker/rotmg-shot-tool:html5"
$TARGET_WINDOWS = "justofisker/rotmg-shot-tool:windows"

function New-TemporaryDirectory {
    $tmp = [System.IO.Path]::GetTempPath() # Not $env:TEMP, see https://stackoverflow.com/a/946017
    $name = (New-Guid).ToString("N")
    New-Item -ItemType Directory -Path (Join-Path $tmp $name)
}

# Web Build
$WEB_BUILD_DIR = New-TemporaryDirectory
& $env:GODOT_BIN --headless --export-release "Web" "$($WEB_BUILD_DIR.FullName)\index.html" | Out-Host
butler push "$($WEB_BUILD_DIR.FullName)" "$TARGET_WEB"
Remove-Item -Recurse -Force $WEB_BUILD_DIR

# # Windows Build
$WINDOWS_BUILD_DIR = New-TemporaryDirectory
& $env:GODOT_BIN --headless --export-release "Windows Desktop" "$($WINDOWS_BUILD_DIR.FullName)\Just's Shot Tool.exe" | Out-Host
Copy-Item -Recurse -Force assets "$($WINDOWS_BUILD_DIR.FullName)\assets"
Get-ChildItem -Path "$($WINDOWS_BUILD_DIR.FullName)\assets" -Recurse -Filter *.import | Remove-Item -Force
Copy-Item -Recurse -Force scripts "$($WINDOWS_BUILD_DIR.FullName)\scripts"
Get-ChildItem -Path "$($WINDOWS_BUILD_DIR.FullName)\scripts" -Recurse -Filter *.uid | Remove-Item -Force
New-Item -ItemType Directory -Path "$($WINDOWS_BUILD_DIR.FullName)\scenes" | Out-Null
butler push "$($WINDOWS_BUILD_DIR.FullName)" "$TARGET_WINDOWS"
Remove-Item -Recurse -Force $WINDOWS_BUILD_DIR
