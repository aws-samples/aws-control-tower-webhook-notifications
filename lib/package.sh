# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#!/usr/bin/env bash
 
# Builds a lambda package from a single Python 3 module with pip dependencies.
# This is a modified version of the AWS packaging instructions:
# https://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html#python-package-dependencies
 
# https://stackoverflow.com/a/246128
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
 
pushd $SCRIPT_DIRECTORY > /dev/null
 
rm -rf .package aws-ct-chime.zip
mkdir .package
 
pip3 install --target .package --requirement requirements.txt
 
pushd .package > /dev/null
zip --recurse-paths ${SCRIPT_DIRECTORY}/aws-ct-chime.zip .
popd > /dev/null
 
zip --grow  aws-ct-chime.zip aws-ct-chime.py
 
popd > /dev/null