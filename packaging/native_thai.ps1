param(
 [ValidateSet('Install','Uninstall')][string]$Action,
 [string]$Studio,
 [string]$Backup,
 [string]$Payload
)
$ErrorActionPreference='Stop'
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Join([string]$a,[string]$b) { return Join-Path $a $b }
$exe=Join $Studio 'bambu-studio.exe'
if(!(Test-Path $exe)){throw "Official Bambu Studio missing: $exe"}
if(Get-Process -Name 'bambu-studio' -ErrorAction SilentlyContinue){throw 'Please close Bambu Studio first.'}
$cfg=Join $env:APPDATA 'BambuStudio\BambuStudio.conf'
$fonts=Join $Studio 'resources\fonts'
$lang=Join $Studio 'resources\i18n'
$web=Join $Studio 'resources\web\device_page\dist'
$record=Join $Backup 'studio_dir.txt'

function Language([string]$target){
 if(!(Test-Path $cfg)){throw "BambuStudio.conf missing: $cfg"}
 $text=[IO.File]::ReadAllText($cfg,$utf8)
 $end=$text.LastIndexOf('}')
 if($end -lt 0){throw 'Config JSON not found'}
 $json=$text.Substring(0,$end+1)
 $object=ConvertFrom-Json -InputObject $json
 if(!$object.app){throw 'Invalid config app section'}
 $re=[regex]'(?<prefix>"language"\s*:\s*")(?<value>[^"]*)(?<suffix>")'
 $items=$re.Matches($json)
 if($items.Count -ne 1){throw "Expected one language key, found $($items.Count)"}
 $item=$items[0]
 $before=$item.Groups['value'].Value
 if($Action -eq 'Install' -and !(Test-Path (Join $Backup 'original_language.txt'))){
  [IO.File]::WriteAllText((Join $Backup 'original_language.txt'),$before,$utf8)
 }
 if($before -eq $target){return}
 $value=$item.Groups['value']
 $json=$json.Substring(0,$value.Index)+$target+$json.Substring($value.Index+$value.Length)
 $test=ConvertFrom-Json -InputObject $json
 if($test.app.language -ne $target){throw 'Config language verification failed'}
 $md5=[Security.Cryptography.MD5]::Create()
 try{$digest=$md5.ComputeHash($utf8.GetBytes($json))}finally{$md5.Dispose()}
 $checksum=[BitConverter]::ToString($digest).Replace('-','')
 $lf=[Environment]::NewLine
 $temp=$cfg+'.thai-patch.tmp'
 [IO.File]::WriteAllText($temp,$json+$lf+'# MD5 checksum '+$checksum+$lf,$utf8)
 Move-Item -LiteralPath $temp -Destination $cfg -Force
}

$fontsMap=@(
 @('HarmonyOS_Sans_SC_Regular.ttf','tahoma.ttf'),
 @('HarmonyOS_Sans_SC_Bold.ttf','tahomabd.ttf')
)
if($Action -eq 'Install'){
 if(!(Test-Path (Join $Payload 'BambuStudio.mo'))){throw 'Thai catalog missing from setup payload'}
 if(!(Test-Path $cfg)){throw 'Start official Bambu Studio once, exit, and retry.'}
 foreach($pair in $fontsMap){
  if(!(Test-Path (Join $fonts $pair[0]))){throw "Official font missing: $($pair[0])"}
  if(!(Test-Path (Join (Join $env:WINDIR 'Fonts') $pair[1]))){throw "Windows Thai font missing: $($pair[1])"}
 }
 if((Test-Path $record) -and (([IO.File]::ReadAllText($record,$utf8).Trim()) -ne $Studio)){throw 'Previous backup belongs to another Bambu Studio folder.'}
 New-Item -ItemType Directory -Path $Backup -Force | Out-Null
 if(!(Test-Path $record)){[IO.File]::WriteAllText($record,$Studio,$utf8)}
 $savedEs=Join $Backup 'original_es.mo'
 if(Test-Path $savedEs){Copy-Item -LiteralPath $savedEs -Destination (Join $lang 'es\BambuStudio.mo') -Force}
 $thai=Join $lang 'th\BambuStudio.mo'
 $savedTh=Join $Backup 'original_th.mo'
 $missingTh=Join $Backup 'th_missing.marker'
 if(!(Test-Path $savedTh) -and !(Test-Path $missingTh)){
  if(Test-Path $thai){Copy-Item -LiteralPath $thai -Destination $savedTh}
  else{[IO.File]::WriteAllText($missingTh,'1',$utf8)}
 }
 New-Item -ItemType Directory -Path (Split-Path $thai) -Force | Out-Null
 Copy-Item -LiteralPath (Join $Payload 'BambuStudio.mo') -Destination $thai -Force
 foreach($pair in $fontsMap){
  $dest=Join $fonts $pair[0]
  $save=Join $Backup $pair[0]
  if(!(Test-Path $save)){Copy-Item -LiteralPath $dest -Destination $save}
  Copy-Item -LiteralPath (Join (Join $env:WINDIR 'Fonts') $pair[1]) -Destination $dest -Force
 }
 $webPayload=Join $Payload 'device_page\dist'
 $webBackup=Join $Backup 'original_web_dist'
 if(Test-Path (Join $webPayload 'index.html')){
  if(!(Test-Path (Join $webBackup 'index.html'))){
   if(!(Test-Path (Join $web 'index.html'))){throw 'Original web interface missing'}
   Move-Item -LiteralPath $web -Destination $webBackup
  }
  if(Test-Path $web){Remove-Item -LiteralPath $web -Recurse -Force}
  Copy-Item -LiteralPath $webPayload -Destination $web -Recurse -Force
 }
 Language 'th_TH'
 Write-Host 'Native Thai activated; genuine EXE and DLL were not modified.'
}
else{
 if(!(Test-Path $record)){throw 'Patch backup registry missing; aborting.'}
 if(([IO.File]::ReadAllText($record,$utf8).Trim()) -ne $Studio){throw 'Backup folder mismatch'}
 foreach($pair in $fontsMap){
  if(!(Test-Path (Join $Backup $pair[0]))){throw "Original font backup missing: $($pair[0])"}
 }
 $oldFile=Join $Backup 'original_language.txt'
 if(!(Test-Path $oldFile)){throw 'Original language not saved'}
 Language ([IO.File]::ReadAllText($oldFile,$utf8).Trim())
 foreach($pair in $fontsMap){
  Copy-Item -LiteralPath (Join $Backup $pair[0]) -Destination (Join $fonts $pair[0]) -Force
 }
 $thai=Join $lang 'th\BambuStudio.mo'
 if(Test-Path (Join $Backup 'original_th.mo')){Copy-Item -LiteralPath (Join $Backup 'original_th.mo') -Destination $thai -Force}
 elseif(Test-Path (Join $Backup 'th_missing.marker')){Remove-Item -LiteralPath $thai -ErrorAction SilentlyContinue}
 if(Test-Path (Join $Backup 'original_es.mo')){Copy-Item -LiteralPath (Join $Backup 'original_es.mo') -Destination (Join $lang 'es\BambuStudio.mo') -Force}
 $webBackup=Join $Backup 'original_web_dist'
 if(Test-Path (Join $webBackup 'index.html')){
  if(Test-Path $web){Remove-Item -LiteralPath $web -Recurse -Force}
  Move-Item -LiteralPath $webBackup -Destination $web
 }
 Write-Host 'Official language, fonts, and web resources restored.'
}
