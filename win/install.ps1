# Define variables
$zipUrl = "https://github.com/mrbandler/.dotfiles/archive/refs/heads/master.zip"
$tempDir = "$HOME\.dotfiles-temp"
$dotfilesDir = "$HOME\.dotfiles2"
$zipPath = "$HOME\dotfiles2.zip"

New-Item -ItemType Directory -Force -Path $dotfilesDir
Invoke-RestMethod -Uri $zipUrl -OutFile $zipPath
Expand-Archive -LiteralPath $zipPath -DestinationPath $tempDir -Force

$readmeDir = Get-ChildItem -Path $tempDir -Recurse | Where-Object { $_.Name -eq 'README.md' } | Select-Object -ExpandProperty DirectoryName -Unique
Get-ChildItem -Path $readmeDir | Move-Item -Destination $dotfilesDir -Force

Remove-Item -Path $zipPath -Force
Remove-Item -Path $tempDir -Recurse -Force

Set-Location -Path $dotfilesDir
# & ".\win\bootstrap.ps1"

git init
git switch -c temp
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/mrbandler/.dotfiles.git
git fetch origin
git switch -c master origin/master
git branch --set-upstream-to=origin/master master
git pull origin master
git branch -D temp
