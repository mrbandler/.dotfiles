# Variables.
$DotFilesPath = Join-Path $HOME ".dotfiles\win\components"
$DotFilesAutodetect = $true
$DotFilesAllowNestedSymlinks = $true
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
$env:KOMOREBI_CONFIG_HOME = "$HOME\.config\komorebi"

# Aliases.
Set-Alias ll ls
Set-Alias whereis where.exe
Set-Alias grep Select-String
Remove-Item Alias:cd
Set-Alias cd z
Set-Alias find fzf
Set-Alias du dust
Remove-Item Alias:cat
Set-Alias cat bat
Set-Alias top btm

# Modules.
Import-Module Terminal-Icons

# Prompt.
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression (&starship init powershell)
