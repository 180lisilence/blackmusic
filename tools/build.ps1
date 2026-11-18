# 黑马云音乐 —— 一键构建脚本
# 用法：
#   .\tools\build.ps1                 # debug 构建
#   .\tools\build.ps1 -Mode release   # release 构建
#   .\tools\build.ps1 -Verify         # 构建后执行交付校验
param(
  [ValidateSet('debug', 'release')][string]$Mode = 'debug',
  [switch]$Verify
)

$ErrorActionPreference = 'Stop'
$deveco = 'D:\TOOL\devecostudio\devecostudioapp\DevEco Studio'
$env:JAVA_HOME = Join-Path $deveco 'jbr'
$env:DEVECO_SDK_HOME = Join-Path $deveco 'sdk'
$env:Path = (Join-Path $deveco 'jbr\bin') + ';' + $env:Path

$node = Join-Path $deveco 'tools\node\node.exe'
$hvigorw = Join-Path $deveco 'tools\hvigor\bin\hvigorw.js'
$root = Split-Path $PSScriptRoot -Parent

Push-Location $root
try {
  & $node $hvigorw --mode module -p module=entry@default -p product=default `
    -p buildMode=$Mode assembleHap --no-daemon
  if ($LASTEXITCODE -ne 0) { throw "hvigor 构建失败（exit=$LASTEXITCODE）" }

  $hap = Join-Path $root 'entry\build\default\outputs\default\entry-default-unsigned.hap'
  $dist = Join-Path $root 'dist'
  New-Item -ItemType Directory -Force -Path $dist | Out-Null
  $target = Join-Path $dist ("HeimaMusic-6.0.0-{0}-unsigned.hap" -f $Mode)
  Copy-Item $hap $target -Force
  Write-Host ("[OK] HAP: {0} ({1:N0} bytes)" -f $target, (Get-Item $target).Length)

  if ($Verify) {
    $py = 'E:\tool\dshaaa\DSH Desktop\resources\office-runtime\primary-runtime\dependencies\python\python.exe'
    & $py (Join-Path $root 'tools\verify_package.py')
  }
}
finally {
  Pop-Location
}
