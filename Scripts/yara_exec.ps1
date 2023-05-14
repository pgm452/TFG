$log_file_path = "C:\Program Files (x86)\ossec-agent\active-response\active-responses.log"
$yara_exe_path = "C:\Program Files (x86)\ossec-agent\yara\yara64.exe"
$yara_rules_path = "C:\Program Files (x86)\ossec-agent\yara\rules\yara_rules.yar"

$sysmon_events = Get-WinEvent -FilterHashtable @{Logname='Microsoft-Windows-Sysmon/Operational';Id=11;StartTime=(Get-Date).AddMinutes(-60)} | Select-Object -Property TargetFilename, Message

foreach ($event in $sysmon_events) {
    # Parse the relevant fields from the Sysmon event message
    $matches = [regex]::Matches($event.Message, "TargetFilename: (.+)\n.*")
    $target_filename = $matches.Groups[1].Value.Trim()

    # Check if the file exists before running YARA scan
    $resolved_path = Resolve-Path $target_filename -ErrorAction SilentlyContinue
    if ($resolved_path) {
        $target_filename = $resolved_path.Path
        # Run YARA scan on the target file
        $yara_output = & $yara_exe_path -f -m $yara_rules_path $target_filename

        # Append the YARA scan results to the log file
        if ($yara_output) {
	    #$output = "wazuh-yara: INFO - File $target_filename matched the following YARA rules:`n$yara_output"
            #$output = "wazuh-yara: info: $yara_output"
	    $output = "wazuh-yara: info: $yara_output`n"
            $output | ConvertTo-Json -Compress
            Write-Output $output

            # Append the payload to the log file
            $output| Out-File -Append -Encoding ascii $log_file_path
        }
    }
}
