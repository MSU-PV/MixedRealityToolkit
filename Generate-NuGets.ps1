<#
.SYNOPSIS
	Evergine MRTK NuGet Packages generator script, (c) 2021 Evergine
.DESCRIPTION
	This script generates NuGet packages for the Mixed Reality Toolkit for Evergine
	It's meant to have the same behavior when executed locally as when it's executed in a CI pipeline.
.EXAMPLE
	<script> -version 3.4.22.288-local
.LINK
	https://evergine.com/
#>

param (
    [Parameter(mandatory=$true)][string]$version,
	[string]$outputFolderBase = "nupkgs",
	[string]$buildVerbosity = "normal",
	[string]$buildConfiguration = "Release",
	[string]$bindingsCsprojPath = "Source\Evergine.MRTK\Evergine.MRTK.csproj",
	[string]$editorCsprojPath = "Source\Evergine.MRTK.Editor\Evergine.MRTK.Editor.csproj"
)

# Utility functions
function LogDebug($line) { Write-Host "##[debug] $line" -Foreground Blue -Background Black }

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
LogDebug "START packaging process"
& dotnet build "$editorCsprojPath" -v:$buildVerbosity -p:Configuration=$buildConfiguration
& dotnet pack "$bindingsCsprojPath" -v:$buildVerbosity -p:Configuration=$buildConfiguration -p:PackageOutputPath="$absoluteOutputFolder" -p:IncludeSymbols=true -p:Version=$version

LogDebug "END packaging process"