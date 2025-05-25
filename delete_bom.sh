#!/bin/bash
# This script is meant to delete the BOM file uploaded during the test.

set -e

bom_file="$1"
if [ -z "$bom_file" ]; then
    echo "Error: BOM file path is required."
    exit 1
fi

bomnipotent_command="bomnipotent_client"
if ! command -v $bomnipotent_command &> /dev/null; then
    bomnipotent_command="bomnipotent_client.exe"
fi

bom_file="$1"
bom_name=$(jq -r '.metadata.component.name' "$bom_file")
bom_version=$(jq -r '.metadata.component.version' "$bom_file")

"$bomnipotent_command" bom delete $bom_name $bom_version
