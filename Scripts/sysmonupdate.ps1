$url = "https://raw.githubusercontent.com/pgm452/TFG/main/Sysmon/sysmonconfig%20v3.xml?token=GHSAT0AAAAAACCIHNNY3OIAV5ABWXXHAXC2ZCWNJFQ" # URL del archivo a descargar
$output = "C:\Program Files (x86)\ossec-agent\tmp\sysmonconfig.xml" # Ruta de salida del archivo descargado
$config = "C:\Program Files (x86)\ossec-agent\tmp\sysmonconfig.xml" # Ruta del archivo de configuración de Sysmon

# Descarga el archivo de la URL especificada
Invoke-WebRequest -Uri $url -OutFile $output

# Ejecuta Sysmon con el archivo de configuración especificado
& "sysmon.exe" -c $config
