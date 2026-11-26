# kTerm.AI installer for Windows (64-bit). Run it again to update:
#   [Net.ServicePointManager]::SecurityProtocol = 'Tls12'; irm https://raw.githubusercontent.com/01-june-0/k-term-ai-releases/main/install.ps1 | iex
# (the TLS 1.2 prefix is for older Windows PowerShell 5.1, which may not reach GitHub otherwise)
# $env:KTERM_BASE_URL overrides where the installer is downloaded from.
# ASCII only on purpose: Windows PowerShell 5.1 reads a saved .ps1 without a BOM
# in the system code page, which would garble Korean text.
# Everything runs from Install-KTermAI on the last line, so a cut-off download runs nothing.

function Install-KTermAI {
    $ErrorActionPreference = 'Stop'
    # Invoke-WebRequest in PowerShell 5.1 is very slow while drawing its progress bar
    $ProgressPreference = 'SilentlyContinue'
    # Windows PowerShell 5.1 may not offer TLS 1.2 by default; GitHub requires it
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $base = 'https://github.com/01-june-0/k-term-ai-releases/releases/latest/download'
    if ($env:KTERM_BASE_URL) { $base = $env:KTERM_BASE_URL }

    if (-not [Environment]::Is64BitOperatingSystem) {
        throw 'kTerm.AI needs 64-bit Windows.'
    }

    $exe = Join-Path $env:TEMP ('kTerm.AI-setup-' + [guid]::NewGuid().ToString('N') + '.exe')
    try {
        Write-Host 'Downloading kTerm.AI...'
        Invoke-WebRequest -UseBasicParsing -Uri "$base/kTerm.AI-windows-x64-setup.exe" -OutFile $exe
        Write-Host 'Starting the kTerm.AI installer...'
        $p = Start-Process -FilePath $exe -Wait -PassThru
        if ($p.ExitCode -ne 0) {
            throw "The installer did not finish (exit code $($p.ExitCode))."
        }
        Write-Host 'kTerm.AI is installed. Open it from the Start menu.'
    }
    finally {
        Remove-Item -LiteralPath $exe -Force -ErrorAction SilentlyContinue
    }
}

Install-KTermAI
