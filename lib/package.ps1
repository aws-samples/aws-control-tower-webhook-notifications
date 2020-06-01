# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

Push-Location $PSScriptRoot

$packagePath = '.package'
If(Test-Path -Path $packagePath)
{
    Remove-Item -Path $packagePath -Recurse
}
New-Item -ItemType Directory -Path $packagePath | 
    Out-Null

Write-Verbose -Message "Restoring Lambda dependancies" -Verbose
Start-Process -FilePath 'pip3' -ArgumentList 'install --target .package --requirement requirements.txt' -NoNewWindow -Wait

Write-Verbose -Message "Creating lambda zip package" -Verbose
Copy-Item -Path 'aws-ct-chime.py' -Destination $packagePath
Compress-Archive -Path "$($packagePath)\*" -DestinationPath 'aws-ct-chime.zip' -Force

Pop-location 