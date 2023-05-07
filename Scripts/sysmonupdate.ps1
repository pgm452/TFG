$url = "https://raw.githubusercontent.com/pgm452/TFG/main/Sysmon/sysmonconfig%20v3.xml?token=GHSAT0AAAAAACCIHNNY3OIAV5ABWXXHAXC2ZCWNJFQ" # URL del archivo a descargar
$output = "C:\Program Files (x86)\ossec-agent\tmp\sysmonconfig.xml" # Ruta de salida del archivo descargado
$config = "C:\Program Files (x86)\ossec-agent\tmp\sysmonconfig.xml" # Ruta del archivo de configuración de Sysmon
$file = "C:\Program Files (x86)\ossec-agent\active-response\active-responses.log"

# Descarga el archivo de la URL especificada
Invoke-WebRequest -Uri $url -OutFile $output

# Ejecuta Sysmon con el archivo de configuración especificado
& "sysmon.exe" -c $config

rm $config

if ($LASTEXITCODE -eq 0) {
    $status_payload = @{
        group = 'sysmon_update'
        status = 'success'
        message = 'Sysmon configuration were updated successfully.'
    } | ConvertTo-Json -Compress
    Write-Output $status_payload

    # Append the payload to the log file
    $status_payload | Out-File -Append -Encoding ascii $file
}
else {
    $error_payload = @{
        group = 'sysmon_update'
        status = 'failure'
        message = 'Failed to update sysmon configuration.'
    } | ConvertTo-Json -Compress
    Write-Output $error_payload

    # Append the payload to the log file
    $error_payload | Out-File -Append -Encoding ascii $file
}