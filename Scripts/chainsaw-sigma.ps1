# Define the download link and file name
$downloadLink = "https://github.com/git-for-windows/git/releases/download/v2.40.0.windows.1/Git-2.40.0-64-bit.exe"
$gitInstaller = "git-latest-windows.exe"

# Define the destination folder for the SIGMA repository
$destinationFolder = "C:\Program Files (x86)\ossec-agent\chainsaw\sigma"

# Create the destination folder if it does not exist
if(!(Test-Path -Path $destinationFolder)){
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Download Git for Windows
Invoke-WebRequest -Uri $downloadLink -OutFile $gitInstaller

# Install Git for Windows
Start-Process -FilePath $gitInstaller -ArgumentList "/VERYSILENT", "/NORESTART", "/LOG=git_install.log" -NoNewWindow -Wait

# Remove the installer
Remove-Item -Path $gitInstaller

# Add Git to the system PATH
$gitBinPath = "${env:ProgramFiles}\Git\cmd"
$env:Path += ";$gitBinPath"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";$gitBinPath"
[Environment]::SetEnvironmentVariable("Path", $env:Path, "Machine")

# Download the SIGMA repository
git clone "https://github.com/SigmaHQ/sigma.git" $destinationFolder
