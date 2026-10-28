# One-time setup so the itw notebooks run in VS Code on Windows.
# From the repo folder, in a VS Code terminal, run:
#     powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
#
# It creates .venv, installs requirements.txt, and checks that PyTorch loads. If Windows blocks it with
#     OSError: [WinError 4551] An Application Control policy has blocked this file
# it tells you why (usually Smart App Control, because PyTorch's DLL files are not signed)
# and opens the Windows Security page where you can turn it off. It changes no settings itself.

$venvDir = Join-Path $PSScriptRoot ".venv"
$venvPython = Join-Path $venvDir "Scripts\python.exe"
$ciPolicyKey = "HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy"

function Test-Torch {
    & $venvPython -c "import torch, sentence_transformers; print('torch', torch.__version__, 'loaded OK')"
    return ($LASTEXITCODE -eq 0)
}

function Get-SmartAppControlState {
    # 0 = Off, 1 = On, 2 = Evaluation; the value is missing on Windows 10
    $value = Get-ItemProperty -Path $ciPolicyKey -Name VerifiedAndReputablePolicyState -ErrorAction SilentlyContinue
    if ($null -eq $value) { return $null }
    return $value.VerifiedAndReputablePolicyState
}

# 1. Python environment and packages
if (-not (Test-Path $venvPython)) {
    Write-Host "Creating .venv ..."
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3 -m venv $venvDir
    } else {
        & python -m venv $venvDir
    }
    if (-not (Test-Path $venvPython)) {
        Write-Host "Could not create .venv. Install Python 3.11 or newer from https://www.python.org/downloads/ (tick 'Add python.exe to PATH'), then run this script again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Installing packages from requirements.txt (the first run takes several minutes) ..."
& $venvPython -m pip install --upgrade pip
& $venvPython -m pip install -r (Join-Path $PSScriptRoot "requirements.txt")
if ($LASTEXITCODE -ne 0) {
    Write-Host "pip install failed, see the error above." -ForegroundColor Red
    exit 1
}

# 2. Check that PyTorch loads
if (Test-Torch) {
    Write-Host ""
    Write-Host "All set. In VS Code open a notebook, click 'Select Kernel' (top right) -> Python Environments -> .venv, then Run All." -ForegroundColor Green
    exit 0
}

# 3. PyTorch is blocked, find out what blocks it
Write-Host ""
Write-Host "Windows is blocking PyTorch (WinError 4551)." -ForegroundColor Yellow
$state = Get-SmartAppControlState

if ($state -eq 1 -or $state -eq 2) {
    Write-Host "Cause: Smart App Control is on. It blocks PyTorch because PyTorch's DLL files are not digitally signed."
    Write-Host "Turning it off fixes this. Microsoft Defender antivirus keeps protecting the PC,"
    Write-Host "but on most Windows 11 versions Smart App Control cannot be turned back on without resetting Windows."
    Write-Host ""
    Write-Host "Opening Windows Security for you. There:"
    Write-Host "  1. Click 'Smart App Control settings' and choose Off"
    Write-Host "  2. Restart the PC"
    Write-Host "  3. Run this script again to confirm PyTorch loads"
    Start-Process "windowsdefender://appbrowser"
    exit 1
}

Write-Host "Smart App Control is not the cause, so the block comes from an App Control policy set by your school or company."
Write-Host "Latest blocks Windows recorded for PyTorch (empty if this window is not running as admin):"
Get-WinEvent -LogName "Microsoft-Windows-CodeIntegrity/Operational" -MaxEvents 500 -ErrorAction SilentlyContinue |
    Where-Object { $_.Message -match "torch" } |
    Select-Object -First 3 |
    Format-List TimeCreated, Id, Message
Write-Host "Only your IT team can allow PyTorch on this laptop. Until then, run the notebooks on Google's servers:"
Write-Host "  - in VS Code: install the 'Google Colab' extension and choose a Colab kernel, or"
Write-Host "  - in the browser: https://colab.research.google.com"
exit 1
