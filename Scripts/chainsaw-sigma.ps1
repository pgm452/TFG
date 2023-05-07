$downloadLink = "https://github.com/git-for-windows/git/releases/download/v2.40.0.windows.1/Git-2.40.0-64-bit.exe"
$gitInstaller = "C:\Program Files (x86)\ossec-agent\active-response\bin\git-latest-windows.exe"

# Define the destination folder for the SIGMA repository
$repo_path= "C:\Program Files (x86)\ossec-agent\chainsaw\sigma"

# Create the destination folder if it does not exist
if(!(Test-Path -Path $repo_path)){
    New-Item -ItemType Directory -Path $repo_path | Out-Null
}else{
    Remove-Item -Recurse -Force $repo_path
}

# Check if Git is already installed
if(!(Get-Command git.exe -ErrorAction SilentlyContinue)) {
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
}

# Download the SIGMA repository
git clone "https://github.com/SigmaHQ/sigma.git" $repo_path

# Define the file path
$file = "C:\Program Files (x86)\ossec-agent\active-response\active-responses.log"

# Output status if Sigma rules were updated
if ($LASTEXITCODE -eq 0) {
    $status_payload = @{
        group = 'Sigma'
        status = 'success'
        message = 'Sigma rules were updated successfully.'
    } | ConvertTo-Json -Compress
    Write-Output $status_payload

    # Append the payload to the log file
    $status_payload | Out-File -Append -Encoding ascii $file
}
else {
    $error_payload = @{
        group = 'Sigma'
        status = 'failure'
        message = 'Failed to update Sigma rules.'
    } | ConvertTo-Json -Compress
    Write-Output $error_payload

    # Append the payload to the log file
    $error_payload | Out-File -Append -Encoding ascii $file
}

