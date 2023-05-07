################################
### Script to execute Chainsaw - Identify Malicious activity recorded in WinEvtLogs using Sigma Rules
################################

##########
# Chainsaw will be run against all event logs found in the default location
# Output converted to JSON and appended to active-responses.log
##########

##########
# Chainsaw Version: v2.5.0
##########

$ErrorActionPreference = "SilentlyContinue"

# Define the destination folder for the SIGMA repository
$repo_path= "C:\Program Files (x86)\ossec-agent\chainsaw\sigma"

# Analyse events recorded in last 5 Minutes. Convert Start Date to Timestamp
$start_date = (Get-Date).AddMinutes(-5)
$from = Get-Date -Date $start_date -UFormat '+%Y-%m-%dT%H:%M:%S'

# Create Chainsaw Output Folder if it doesn't exist
$chainsaw_output = "$env:TMP\chainsaw_output"
If(!(test-path $chainsaw_output)) {
    New-Item -ItemType Directory -Force -Path $chainsaw_output
}

# Windows Sigma Path
$windows_path = "C:\Program Files (x86)\ossec-agent\chainsaw\sigma\rules\windows"

# Run Chainsaw and store JSONs in TMP folder
& 'C:\Program Files (x86)\ossec-agent\chainsaw\chainsaw.exe' hunt C:\Windows\System32\winevt -s $windows_path --mapping 'C:\Program Files (x86)\ossec-agent\chainsaw\mappings\sigma-event-logs-all.yml' --from $from --output $env:TMP\chainsaw_output\results.json --json --level high --level critical

# Convert JSON to new line entry for every 'group'
function Convert-JsonToNewLine($json) {
    foreach($document in $json) {
        $document.document | ConvertTo-Json -Compress -Depth 99 | foreach-object {
            [pscustomobject]@{
                group = $document.group
                kind = $document.kind	
                document = $_
                event = $document.document.data.Event.EventData
                path = $document.document.path
                system = $document.document.data.Event.System
                name = $document.name
                timestamp = $document.timestamp
                authors = $document.authors
                level = $document.level
                source = $document.source
                status = $document.status
                falsepositives = $document.falsepositives
                id = $document.id
                logsource = $document.logsource
                references = $document.references
                tags = $document.tags
            } | ConvertTo-Json -Compress
        }
    }
}

# Define the file path
$file = "C:\Program Files (x86)\ossec-agent\active-response\active-responses.log"

# Convert JSONs to new line entry and append to active-responses.log
Get-ChildItem $env:TMP\chainsaw_output -Filter *.json | Foreach-Object {
    $Chainsaw_Array = Get-Content $_.FullName | ConvertFrom-Json
    Convert-JsonToNewLine $Chainsaw_Array | Out-File -Append -Encoding ascii $file
}

# Remove TMP JSON Folder
rm -r $env:TMP\chainsaw_output