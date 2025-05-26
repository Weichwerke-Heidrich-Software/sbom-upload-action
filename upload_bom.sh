#!/bin/bash

set -eou pipefail

name=""
version=""
tlp=""
on_existing="error"

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
        --on-existing)
            on_existing="$2"
            shift 2
            ;;
        --on-existing=*)
            on_existing="${1#*=}"
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

if [ -f "$name" ]; then
    echo "Reading BOM name from file: $name"
    name=$(head -n 1 "$name" | head -c 256)
fi
if [ -f "$version" ]; then
    echo "Reading BOM version from file: $version"
    version=$(head -n 1 "$version" | head -c 256)
fi

already_exists=0
if [ "$on_existing" != "error" ]; then
    if [ -n "$name" ] && [ -n "$version" ]; then
        code=$("$bomnipotent_command" --output-mode code bom get "$name" "$version" || true)
        already_exists=$([ "$code" = "200" ] && echo 1 || echo 0)
    else
        echo "Warning: --on-existing handling currently requires --name and --version to be set."
        echo "Weichwerke Heidrich Software is working on a cleaner solution."
    fi
fi
if [ "$already_exists" -eq 1 ]; then
    if [ "$on_existing" == "skip" ]; then
        echo "Skipping upload: BOM with name '$name' and version '$version' already exists."
        exit 0
    elif [ "$on_existing" == "replace" ]; then
        "$bomnipotent_command" bom delete "$name" "$version"
    else
        echo "Error: BOM with name '$name' and version '$version' already exists."
        exit 1
    fi
fi


args=(bom upload "$bom_file")
[ -n "$name" ] && args+=(--name-overwrite "$name")
[ -n "$version" ] && args+=(--version-overwrite "$version")
[ -n "$tlp" ] && args+=(--tlp "$tlp")

"$bomnipotent_command" "${args[@]}"
