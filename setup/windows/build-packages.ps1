$Hash32 = Get-FileHash "$env:BUILD_ARTIFACTSTAGINGDIRECTORY\publish\qbittorrent-cli-$env:BUILD_BUILDNUMBER-x86.msi"
$Hash64 = Get-FileHash "$env:BUILD_ARTIFACTSTAGINGDIRECTORY\publish\qbittorrent-cli-$env:BUILD_BUILDNUMBER-x64.msi"

pushd "$env:BUILD_BINARIESDIRECTORY"

$RepoPath = "$env:BUILD_BINARIESDIRECTORY\qbittorrent-cli"
if (Test-Path "$RepoPath") {
    Remove-Item "$RepoPath" -Recurse -Force
}

#https://github.com/fedarovich/qbittorrent-cli/releases/download/v1.6.21114.2/qbittorrent-cli-1.6.21114.2-x64.msi

choco new qbittorrent-cli `
    --verbose `
    --version=$env:BUILD_BUILDNUMBER `
    --maintainer="Pavel Fedarovich" `
    maintainerrepo="https://github.com/fedarovich/qbittorrent-cli" `
    installertype=msi `
    url="https://github.com/fedarovich/qbittorrent-cli/releases/download/v$env:BUILD_BUILDNUMBER/qbittorrent-cli-$env:BUILD_BUILDNUMBER-x86.msi" `
    url64="https://github.com/fedarovich/qbittorrent-cli/releases/download/v$env:BUILD_BUILDNUMBER/qbittorrent-cli-$env:BUILD_BUILDNUMBER-x64.msi" `
    checksum="$($Hash32.Hash)" `
    checksum64="$($Hash64.Hash)"

& "$env:BUILD_SOURCESDIRECTORY\setup\windows\NuSpecGen\bin\Release\NuSpecGen.exe" -v $env:BUILD_BUILDNUMBER -o "$env:BUILD_BINARIESDIRECTORY\qbittorrent-cli\qbittorrent-cli.nuspec"

pushd qbittorrent-cli

Invoke-WebRequest https://rawcdn.githack.com/fedarovich/qbittorrent-cli/e8ae9f9c6a2048eec8ef06a70c2a4ade0e7bcaed/LICENSE -OutFile .\tools\LICENSE.txt

cp -Path "$env:BUILD_SOURCESDIRECTORY\setup\windows\VERIFICATION.txt" -Destination .\tools\VERIFICATION.txt -Force

# Remove comments from the chocolateyinstall.ps1 script
$f="$env:BUILD_BINARIESDIRECTORY\qbittorrent-cli\tools\chocolateyinstall.ps1"
gc $f | ? {$_ -notmatch "^\s*#"} | % {$_ -replace '(^.*?)\s*?[^``]#.*','$1'} | Out-File $f+".~" -en utf8; mv -fo $f+".~" $f

if (-Not (Test-Path "$env:BUILD_ARTIFACTSTAGINGDIRECTORY\pkg")) {
    New-Item "$env:BUILD_ARTIFACTSTAGINGDIRECTORY\pkg\chocolatey" -ItemType Directory
}
choco pack --verbose --outputdirectory "$env:BUILD_ARTIFACTSTAGINGDIRECTORY\pkg\chocolatey"

popd
popd
