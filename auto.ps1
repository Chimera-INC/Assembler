# Get the current directory of the script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define the directory where the repositories will be downloaded
$downloadDir = Join-Path $scriptDir "github-repos"

# Create the directory if it doesn't exist
if (-not (Test-Path $downloadDir)) {
  New-Item -ItemType Directory -Path $downloadDir | Out-Null
}

# Define an array of GitHub repositories to download
$repos = @(
  "https://github.com/Chimera-INC/mods/archive/refs/heads/master.zip"
  "https://github.com/Chimera-INC/config/archive/refs/heads/master.zip"
  "https://github.com/Chimera-INC/Assembler/archive/refs/heads/master.zip"
)

# Loop through the array and download each repository
foreach ($repo in $repos) {
  $repoName = [System.IO.Path]::GetFileNameWithoutExtension($repo).Replace("-master", "")
  $repoDir = Join-Path $downloadDir $repoName
  if (-not (Test-Path $repoDir)) {
    $tempZip = Join-Path $downloadDir "$repoName.zip"
    Invoke-WebRequest -Uri $repo -OutFile $tempZip
    Expand-Archive -Path $tempZip -DestinationPath $repoDir
    Remove-Item $tempZip
  } else {
    $tempZip = Join-Path $downloadDir "$repoName.zip"
    Invoke-WebRequest -Uri $repo -OutFile $tempZip
    $repoDirFiles = Get-ChildItem $repoDir -Recurse | Select-Object FullName
    $tempZipFiles = (Expand-Archive -Path $tempZip).FullName
    $diffFiles = Compare-Object -ReferenceObject $repoDirFiles -DifferenceObject $tempZipFiles -Exclude ".git" -PassThru
    if ($diffFiles) {
      Remove-Item $repoDir -Recurse -Force
      Expand-Archive -Path $tempZip -DestinationPath $repoDir
    }
    Remove-Item $tempZip
  }
}

# Move the downloaded repositories to the script directory
if ((Get-ChildItem $downloadDir).Count -gt 0) {
  Copy-Item -Recurse -Path $downloadDir\* -Destination $scriptDir
}
Remove-Item -Recurse -Force $downloadDir

# Remove unwanted files from downloaded repositories
Get-ChildItem -Path $scriptDir -Filter "README.md" -Recurse | Remove-Item -Recurse -Force
