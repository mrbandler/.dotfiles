# Install dotfiles.
Install-DotFiles -Path "$HOME/.dotfiles/win"
Add-Content -Path $PROFILE.CurrentUserAllHosts -Value ". $HOME/profile.ps1"

# Source profile.
. $HOME/profile.ps1
