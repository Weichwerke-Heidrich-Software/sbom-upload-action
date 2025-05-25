#!/bin/bash

set -eou pipefail

name=""
version=""
tlp=""

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--name)
            name="$2"
            shift 2
            ;;
        --name=*)
            name="${1#*=}"
            shift
            ;;
        -v|--version)
            version="$2"
            shift 2
            ;;
        --version=*)
            version="${1#*=}"
            shift
            ;;
        -t|--tlp)
            tlp="$2"
            shift 2
            ;;
        --tlp=*)
            tlp="${1#*=}"
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            bom_file="$1"
            shift
            ;;
    esac
done

if [ -z "$bom_file" ]; then
    echo "Error: BOM file path is required."
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

args=(bom upload "$bom_file")
[ -n "$name" ] && args+=(--name-overwrite "$name")
[ -n "$version" ] && args+=(--version-overwrite "$version")
[ -n "$tlp" ] && args+=(--tlp "$tlp")

"$bomnipotent_command" "${args[@]}"
