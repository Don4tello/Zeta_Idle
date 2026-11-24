# Pull the Firestore `telemetry` collection to a local JSON file for analysis.
# Uses your gcloud login (run `gcloud auth login` once first) - no service-account
# key needed. gcloud auth carries your project IAM role, so reads bypass the
# create-only client rules.
#
# Pulls NEWEST-FIRST (ordered by `ts` descending) via Firestore runQuery, so a
# capped pull always returns the most recent events - not an arbitrary slice.
#
# Usage:  powershell -ExecutionPolicy Bypass -File tool/pull_telemetry.ps1 [-Limit 5000] [-OutFile path]
param(
  [int]$Limit = 5000,
  [string]$OutFile = "C:\ZetaIdle\telemetry_dump.json"
)
$ErrorActionPreference = "Stop"
$project = "zetaidle-20260602-01"

$token = (gcloud auth print-access-token 2>$null)
if (-not $token) {
  Write-Output "NOT AUTHENTICATED - run: gcloud auth login  (then re-run)"
  exit 1
}
$headers = @{ Authorization = ("Bearer " + $token); "Content-Type" = "application/json" }
$runUrl = "https://firestore.googleapis.com/v1/projects/" + $project + "/databases/(default)/documents:runQuery"

# Page newest-first with a startAt cursor on `ts`, so we can exceed a single
# runQuery response and still stop at -Limit. Single-field orderBy needs no
# manual index (Firestore auto-indexes single fields).
$docs = @()
$cursorTs = $null
do {
  $take = [Math]::Min(1000, $Limit - $docs.Count)
  $sq = @{
    from    = @(@{ collectionId = "telemetry" })
    orderBy = @(@{ field = @{ fieldPath = "ts" }; direction = "DESCENDING" })
    limit   = $take
  }
  # startAt a cursor that is strictly AFTER the last ts we saw (before=$false),
  # so paging doesn't repeat the boundary doc.
  if ($cursorTs) { $sq["startAt"] = @{ values = @(@{ timestampValue = $cursorTs }); before = $false } }
  $body = @{ structuredQuery = $sq } | ConvertTo-Json -Depth 12

  $resp  = Invoke-RestMethod -Headers $headers -Uri $runUrl -Method Post -Body $body
  $batch = @($resp | Where-Object { $_.document } | ForEach-Object { $_.document })
  if ($batch.Count -eq 0) { break }

  $docs = $docs + $batch
  $cursorTs = $batch[-1].fields.ts.timestampValue
} while ($docs.Count -lt $Limit -and $cursorTs)

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
Write-Output ("pulled " + $rows.Count + " telemetry docs (newest-first) -> " + $OutFile)
