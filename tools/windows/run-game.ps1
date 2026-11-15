#requires -Version 5.1
<#
Windows x64 portable bootstrap. No administrator, PATH change or extra runtime.
The pinned archive hash is from the official Godot GitHub release asset digest.
#>
[CmdletBinding()]
param(
    [switch]$NoLaunch,
    [switch]$Offline,
    [switch]$SmokeTest,
    [string]$ToolsDirectory = ''
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$ProjectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$EngineVersion = '4.7.2'
$ArchiveName = 'Godot_v4.7.2-stable_win64.exe.zip'
$ArchiveSha256 = '731980f9608d61333e5baf54a2ef17210acc7a538446c0cb9969f002aca1e953'
$ArchiveUrl = 'https://github.com/godotengine/godot/releases/download/4.7.2-stable/' + $ArchiveName
$LaunchLog = $null

function Write-Status([string]$Message) {
    $line = '[' + (Get-Date -Format 'HH:mm:ss') + '] ' + $Message
    Write-Host $line
    if ($script:LaunchLog) { Add-Content -LiteralPath $script:LaunchLog -Value $line -Encoding UTF8 }
}

function Assert-ProjectChild([string]$Path) {
    $resolved = [IO.Path]::GetFullPath($Path)
    $prefix = $script:ProjectRoot.TrimEnd('\') + '\'
    if (-not $resolved.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Install/cache paths must remain inside this project directory.'
    }
    return $resolved
}

function Quote-NativeArgument([string]$Value) {
    # Win32 command-line quoting also works in Windows PowerShell 5.1.
    $escaped = [regex]::Replace($Value, '(\\*)"', '$1$1\"')
    $escaped = [regex]::Replace($escaped, '(\\+)$', '$1$1')
    return '"' + $escaped + '"'
}

function New-GodotStartInfo([string]$Executable, [string[]]$GodotArguments) {
    $info = New-Object Diagnostics.ProcessStartInfo
    $info.FileName = $Executable
    $info.WorkingDirectory = $script:ProjectRoot
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.WindowStyle = [Diagnostics.ProcessWindowStyle]::Normal
    $quoted = @($GodotArguments | ForEach-Object { Quote-NativeArgument $_ })
    $info.Arguments = [string]::Join(' ', $quoted)
    $info.EnvironmentVariables['APPDATA'] = $script:RuntimeData
    if ($script:Offline -or $script:SmokeTest) {
        $info.EnvironmentVariables['LUNAR_OFFLINE'] = '1'
    } else {
        $info.EnvironmentVariables.Remove('LUNAR_OFFLINE')
    }
    return $info
}

function Invoke-GodotCheck([string]$Executable, [string[]]$GodotArguments, [string]$Name, [int]$TimeoutSeconds = 180) {
    $info = New-GodotStartInfo $Executable $GodotArguments
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $process = [Diagnostics.Process]::Start($info)
    $stdout = $process.StandardOutput.ReadToEndAsync()
    $stderr = $process.StandardError.ReadToEndAsync()
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        $process.Kill()
        throw ($Name + ' timed out. Close unused applications and retry. Only this launcher child was stopped.')
    }
    $process.WaitForExit()
    $output = $stdout.Result + [Environment]::NewLine + $stderr.Result
    $checkLog = Join-Path $script:ProjectRoot ('logs\' + $Name + '.log')
    [IO.File]::WriteAllText($checkLog, $output, (New-Object Text.UTF8Encoding($false)))
    if ($process.ExitCode -ne 0 -or $output -match '(?m)^\s*(SCRIPT ERROR:|ERROR:|Parse Error:)') {
        throw ($Name + ' failed. See ' + $checkLog)
    }
    return $output.Trim()
}

function Install-Godot {
    $downloadRoot = Assert-ProjectChild (Join-Path $script:ToolsRoot 'downloads')
    New-Item -ItemType Directory -Force -Path $downloadRoot | Out-Null
    $archive = Assert-ProjectChild (Join-Path $downloadRoot $script:ArchiveName)
    $validCache = (Test-Path -LiteralPath $archive -PathType Leaf) -and
        ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -eq $script:ArchiveSha256)
    if (-not $validCache) {
        Write-Status 'Godot is missing. Downloading the official Windows x64 package (about 86 MB)...'
        $partial = Assert-ProjectChild ($archive + '.' + [Guid]::NewGuid().ToString('N') + '.partial')
        $previousTls = [Net.ServicePointManager]::SecurityProtocol
        try {
            [Net.ServicePointManager]::SecurityProtocol = $previousTls -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -UseBasicParsing -Uri $script:ArchiveUrl -OutFile $partial -TimeoutSec 600 -UserAgent 'Lunar-Base-Rewind-Launcher'
        } finally {
            [Net.ServicePointManager]::SecurityProtocol = $previousTls
        }
        if ((Get-FileHash -LiteralPath $partial -Algorithm SHA256).Hash -ne $script:ArchiveSha256) {
            throw 'Official package SHA256 mismatch. The downloaded file was NOT installed or executed. Retry later.'
        }
        Move-Item -LiteralPath $partial -Destination $archive -Force
    }
    Write-Status 'SHA256 verified. Installing Godot inside this project...'
    $stage = Assert-ProjectChild (Join-Path $downloadRoot ('extract-' + [Guid]::NewGuid().ToString('N')))
    New-Item -ItemType Directory -Path $stage | Out-Null
    Expand-Archive -LiteralPath $archive -DestinationPath $stage
    foreach ($name in @($script:ConsoleName, $script:GuiName)) {
        $source = Join-Path $stage $name
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw ('Official archive is missing ' + $name) }
        Copy-Item -LiteralPath $source -Destination (Join-Path $script:EngineRoot $name) -Force
    }
    # Only the extracted files created in this verified staging directory are removed.
    $safeStage = Assert-ProjectChild $stage
    Remove-Item -LiteralPath $safeStage -Recurse -Force
}

try {
    if (-not [Environment]::Is64BitOperatingSystem -or $env:OS -ne 'Windows_NT') {
        throw 'RUN_GAME.cmd supports Windows 10/11 x64. Other systems: install Godot 4.7.2 Standard and open project.godot.'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $ProjectRoot 'project.godot') -PathType Leaf)) {
        throw 'Project files are missing. Extract the entire downloaded repository ZIP before running RUN_GAME.cmd.'
    }
    $logRoot = Assert-ProjectChild (Join-Path $ProjectRoot 'logs')
    New-Item -ItemType Directory -Force -Path $logRoot | Out-Null
    $LaunchLog = Join-Path $logRoot ('launcher-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    if ([string]::IsNullOrWhiteSpace($ToolsDirectory)) { $ToolsDirectory = Join-Path $ProjectRoot '.tools' }
    if (-not [IO.Path]::IsPathRooted($ToolsDirectory)) { $ToolsDirectory = Join-Path $ProjectRoot $ToolsDirectory }
    $ToolsRoot = Assert-ProjectChild $ToolsDirectory
    $EngineRoot = Assert-ProjectChild (Join-Path $ToolsRoot ('godot-' + $EngineVersion))
    $RuntimeData = Assert-ProjectChild (Join-Path $EngineRoot 'editor_data\runtime_appdata')
    New-Item -ItemType Directory -Force -Path $EngineRoot, $RuntimeData | Out-Null
    $ConsoleName = 'Godot_v' + $EngineVersion + '-stable_win64_console.exe'
    $GuiName = 'Godot_v' + $EngineVersion + '-stable_win64.exe'
    $console = Join-Path $EngineRoot $ConsoleName
    $gui = Join-Path $EngineRoot $GuiName
    if (-not (Test-Path -LiteralPath $console -PathType Leaf) -or -not (Test-Path -LiteralPath $gui -PathType Leaf)) {
        Install-Godot
    } else {
        Write-Status 'Using the existing project-local Godot installation. No download required.'
    }
    New-Item -ItemType File -Force -Path (Join-Path $EngineRoot '_sc_') | Out-Null
    $version = Invoke-GodotCheck $console @('--headless', '--version') 'launcher-version' 30
    if ($version -notmatch '^4\.7\.2\.stable') {
        throw ('Expected Godot 4.7.2 Standard, found: ' + $version + '. Move the project-local engine folder aside and retry.')
    }
    Write-Status ('Godot ' + $version)
    Write-Status 'Preparing project assets. The first import can take a minute...'
    $null = Invoke-GodotCheck $console @('--headless', '--path', $ProjectRoot, '--editor', '--import', '--quit') 'launcher-import' 600
    if ($SmokeTest) {
        Write-Status 'Checking the game scene with bundled offline NASA data...'
        $null = Invoke-GodotCheck $console @('--headless', '--path', $ProjectRoot, '--quit-after', '120') 'launcher-smoke' 90
    }
    if ($NoLaunch -or $SmokeTest) {
        Write-Status 'READY: installation and project import succeeded. Run RUN_GAME.cmd to play.'
        exit 0
    }
    $gameLog = Join-Path $logRoot ('game-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
    Write-Status 'Opening Lunar Base Rewind. Click Start Training in the game window. Close the game to finish.'
    $gameInfo = New-GodotStartInfo $gui @('--path', $ProjectRoot, '--windowed', '--log-file', $gameLog)
    $game = [Diagnostics.Process]::Start($gameInfo)
    Write-Status ('Game PID ' + $game.Id + '. Log: ' + $gameLog)
    $game.WaitForExit()
    if ($game.ExitCode -ne 0) { throw ('Game exited with code ' + $game.ExitCode + '. See ' + $gameLog) }
    Write-Status 'Game closed.'
    exit 0
} catch {
    Write-Status ('ERROR: ' + $_.Exception.Message)
    Write-Host 'If installation needs a download, connect to the internet and retry. Logs are inside the project logs folder.'
    exit 1
}
