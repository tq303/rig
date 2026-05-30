@echo off
setlocal

where winget >nul 2>nul
if %errorlevel% neq 0 (
    echo winget not found. Install "App Installer" from the Microsoft Store and re-run.
    exit /b 1
)

REM git
winget install --id Git.Git -e --source winget

REM languages
winget install --id GoLang.Go -e --source winget
winget install --id OpenJS.NodeJS.LTS -e --source winget

REM editors
winget install --id Microsoft.VisualStudioCode -e --source winget

REM tools
winget install --id Neovim.Neovim -e --source winget
winget install --id BurntSushi.ripgrep.MSVC -e --source winget
winget install --id sharkdp.fd -e --source winget
winget install --id junegunn.fzf -e --source winget
winget install --id sharkdp.bat -e --source winget
winget install --id GitHub.cli -e --source winget
winget install --id JesseDuffield.lazygit -e --source winget
winget install --id astral-sh.uv -e --source winget
winget install --id Gyan.FFmpeg -e --source winget

REM valet (requires go — open a new terminal first if go was just installed)
go install github.com/tq303/valet@latest
go install github.com/tq303/rip@latest
%USERPROFILE%\go\bin\valet sync --platform windows

echo.
echo Done. Restart your terminal for PATH changes to take effect.
endlocal
