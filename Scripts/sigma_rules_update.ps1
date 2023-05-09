$url = "https://github.com/git-for-windows/git/releases/download/v2.40.0.windows.1/Git-2.40.0-64-bit.exe" # URL del archivo a descargar
$gitInstaller = "C:\Program Files (x86)\ossec-agent\active-response\bin\git-latest-windows.exe"
$output = "C:\Program Files (x86)\ossec-agent\sigma" # Ruta de salida del archivo descargado
$file = "C:\Program Files (x86)\ossec-agent\active-response\active-responses.log"

# Create the destination folder if it does not exist
if(!(Test-Path -Path $output)){
    New-Item -ItemType Directory -Path $output\rules | Out-Null
}else{
    Remove-Item -Recurse -Force $output\rules
}

# Check if Git is already installed
if(!(Get-Command git.exe -ErrorAction SilentlyContinue)) {
    # Download Git for Windows
    Invoke-WebRequest -Uri $url -OutFile $gitInstaller

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

Invoke-WebRequest -Uri https://github.com/WithSecureLabs/chainsaw/releases/download/v2.6.0/chainsaw_x86_64-pc-windows-msvc.zip -OutFile $output\chainsaw_x86_64-pc-windows-msvc.zip
cd $output; 
Expand-Archive chainsaw_x86_64-pc-windows-msvc.zip; Remove-Item chainsaw_x86_64-pc-windows-msvc.zip 
mv chainsaw_x86_64-pc-windows-msvc\chainsaw\* .
Remove-Item -Recurse -Force chainsaw_x86_64-pc-windows-msvc

# Download the SIGMA repository
git clone "https://github.com/SigmaHQ/sigma.git" $output\rules

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

