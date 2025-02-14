<#
.SYNOPSIS
	Evergine MRTK Assets Packages generator script, (c) 2022 Evergine
.DESCRIPTION
	This script generates Assets packages for the Mixed Reality Toolkit for Evergine
	It's meant to have the same behavior when executed locally as when it's executed in a CI pipeline.
.EXAMPLE
	<script> -version 2022.2.11.1-local
.LINK
	https://evergine.com/
#>

param (
	[Parameter(mandatory=$true)][string]$version,
	[string]$outputFolderBase = "wepkgs",
	[string]$buildVerbosity = "normal",
	[string]$buildConfiguration = "Release",
	[string]$assetsCsprojPath = "Source\Evergine.MRTK.Assets\Evergine.MRTK.Assets.csproj"
)

# Utility functions
function LogDebug($line)
{ Write-Host "##[debug] $line" -Foreground Blue -Background Black
}

# Show variables
LogDebug "############## VARIABLES ##############"
LogDebug "Version.............: $version"
LogDebug "Build configuration.: $buildConfiguration"
LogDebug "Build verbosity.....: $buildVerbosity"
LogDebug "Output folder.......: $outputFolderBase"
LogDebug "#######################################"

# Create output folder
New-Item -ItemType Directory -Force -Path $outputFolderBase
$absoluteOutputFolder = Resolve-Path $outputFolderBase

# Generate packages
LogDebug "START assets packaging process"
& dotnet build "$assetsCsprojPath" -v:$buildVerbosity -p:Configuration=$buildConfiguration -t:CreateEvergineAddOn -p:Version=$version -o "$absoluteOutputFolder"

LogDebug "END assets packaging process"
