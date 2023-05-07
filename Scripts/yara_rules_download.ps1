$url = "https://github.com/pgm452/TFG/raw/main/Yara/yara_rules.yar" # URL del archivo a descargar
$output = "C:\Program Files (x86)\ossec-agent\yara" # Ruta de salida del archivo descargado
$file = "C:\Program Files (x86)\ossec-agent\active-response\active-responses.log"

# Create the destination folder if it does not exist
if(!(Test-Path -Path $output)){
    New-Item -ItemType Directory -Path $output\rules | Out-Null
}else{
    Remove-Item -Recurse -Force $output\*
    New-Item -ItemType Directory -Path $output\rules | Out-Null
}

Invoke-WebRequest -Uri https://github.com/VirusTotal/yara/releases/download/v4.3.1/yara-4.3.1-2141-win64.zip -OutFile $output\v4.2.3-2029-win64.zip
cd $output; 
Expand-Archive v4.2.3-2029-win64.zip; Remove-Item v4.2.3-2029-win64.zip 
mv v4.2.3-2029-win64\* .
rm v4.2.3-2029-win64


# Descarga el archivo de la URL especificada
Invoke-WebRequest -Uri $url -OutFile $output\rules\yara_rules.yar

if ($LASTEXITCODE -eq 0) {
    $status_payload = @{
        group = 'yara_update'
        status = 'success'
        message = 'Yara-rules.yar downloaded successfully.'
    } 
    $error_payload | Out-File -Append -Encoding ascii $file
}
else {
    $error_payload = @{
        group = 'yara_update'
        status = 'failure'
        message = 'Yara-rules.yar downloaded Failed.'
    }
    $error_payload | Out-File -Append -Encoding ascii $file
}