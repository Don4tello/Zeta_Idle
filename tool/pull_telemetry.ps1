# Pull the Firestore `telemetry` collection to a local JSON file for analysis.
# Uses your gcloud login (run `gcloud auth login` once first) — no service-account
# key needed. gcloud auth carries your project IAM role, so reads bypass the
# create-only client rules.
#
# Usage:  powershell -ExecutionPolicy Bypass -File tool/pull_telemetry.ps1 [-Limit 1000] [-OutFile path]
param(
  [int]$Limit = 1000,
  [string]$OutFile = "C:\ZetaIdle\telemetry_dump.json"
)
$ErrorActionPreference = "Stop"
$project = "zetaidle-20260602-01"

$token = (gcloud auth print-access-token 2>$null)
if (-not $token) {
  Write-Output "NOT AUTHENTICATED - run: gcloud auth login  (then re-run)"
  exit 1
}
$headers = @{ Authorization = ("Bearer " + $token) }
$base = "https://firestore.googleapis.com/v1/projects/" + $project + "/databases/(default)/documents/telemetry"

$docs = @()
$pageToken = $null
do {
  $url = $base + "?pageSize=300"
  if ($pageToken) { $url = $url + "&pageToken=" + $pageToken }
  $resp = Invoke-RestMethod -Headers $headers -Uri $url -Method Get
  if ($resp.documents) { $docs = $docs + $resp.documents }
  $pageToken = $resp.nextPageToken
} while ($pageToken -and ($docs.Count -lt $Limit))

function Flatten($d) {
  $o = [ordered]@{}
  foreach ($p in $d.fields.PSObject.Properties) {
    $v = $p.Value
    if     ($null -ne $v.stringValue)    { $o[$p.Name] = $v.stringValue }
    elseif ($null -ne $v.integerValue)   { $o[$p.Name] = [int64]$v.integerValue }
    elseif ($null -ne $v.doubleValue)    { $o[$p.Name] = [double]$v.doubleValue }
    elseif ($null -ne $v.booleanValue)   { $o[$p.Name] = [bool]$v.booleanValue }
    elseif ($null -ne $v.timestampValue) { $o[$p.Name] = $v.timestampValue }
    else { $o[$p.Name] = ($v | ConvertTo-Json -Compress) }
  }
  $o['_createTime'] = $d.createTime
  return [pscustomobject]$o
}

$rows = @()
foreach ($d in $docs) { $rows = $rows + (Flatten $d) }
$rows | ConvertTo-Json -Depth 6 | Out-File -FilePath $OutFile -Encoding utf8
Write-Output ("pulled " + $rows.Count + " telemetry docs -> " + $OutFile)
