#!/bin/bash

set -e

sbom_file="$1"
if [ -z "$sbom_file" ]; then
    echo "Error: SBOM file path is required."
    exit 1
fi

bomnipotent_command="bomnipotent_client"
if ! command -v $bomnipotent_command &> /dev/null; then
    bomnipotent_command="bomnipotent_client.exe"
fi
if ! command -v $bomnipotent_command &> /dev/null; then
    echo "Error: The BOMnipotent Client binary is not available in the PATH. Please make sure it is."
    echo "Inside GitHub Actions, you can use Weichwerke-Heidrich-Software/setup-bomnipotent-action to that end."
    echo "https://github.com/marketplace/actions/setup-bomnipotent-client"
    exit 1
fi
