[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet('Leap','Leap_Micro','Tumbleweed')]
    [string]
    $Distro
)

#Verify the pre-request
@"
packer
dos2unix
"@ -split "`r`n" | ForEach-Object {
  if (!(Get-Command $_)) {
    [bool]$Ready = $false
  }
  $Ready
}

# Build images
if ($Ready -ne $false) {
  # Convert dos format to unix format
  "dos2unix"
  Get-ChildItem -Path $PSScriptRoot -Recurse -Filter "*.sh" `
    | Select-Object -ExpandProperty VersionInfo `
    | Select-Object -ExpandProperty filename `
    | ForEach-Object {
      #[io.file]::WriteAllText($_, ((Get-Content -Raw  $_) -replace "`r`n","`n"))
      dos2unix $_
    }

  # Get Start Time
  $startDTM = (Get-Date)
  
  # Variables
  if ($Distro = "Tumbleweed") {
    $template_file="$PSScriptRoot\tmpl-hv_g2-openSUSE_Tumbleweed.pkr.hcl"
  }
  else {
    $template_file="$PSScriptRoot\tmpl-hv_g2-openSUSE.pkr.hcl"
  }
  $var_file="$PSScriptRoot\vars-openSUSE_$Distro.pkrvars.hcl"
  $machine="openSUSE_$Distro-g2"
  $packer_log=0
  
  if ((Test-Path -Path "$template_file") -and (Test-Path -Path "$var_file")) {
    Write-Output "Template and var file found"
    Write-Output "Building: $machine"
    $currentLocation = (Get-Location).Path
    Set-Location $PSScriptRoot
    try {
      $env:PACKER_LOG=$packer_log
      packer validate -var-file="$var_file" "$template_file"
    }
    catch {
      Write-Output "Packer validation failed, exiting."
      exit (-1)
    }
    try {
      $env:PACKER_LOG=$packer_log
      packer version
      packer build --force -var-file="$var_file" "$template_file"
    }
    catch {
      Write-Output "Packer build failed, exiting."
      exit (-1)
    }
    Set-Location $currentLocation
  }
  else {
    Write-Output "Template or var file not found - exiting"
    exit (-1)
  }
}

$endDTM = (Get-Date)
Write-Host "[INFO]  - Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds" -ForegroundColor Yellow
