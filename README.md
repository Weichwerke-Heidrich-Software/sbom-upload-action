# Upload BOM

![BOMnipotent Logo](https://www.bomnipotent.de/images/bomnipotent_banner.svg)

[BOMnipotent](https://www.bomnipotent.de) is a pair of server and client application for hosting and managing documents around supply chain security, like SBOMs and CSAF documents.

This project is a GitHub action that allows users to upload a Bill of Materials (BOM) to an instance of BOMnipotent Server.

However, everything that happens is intentionally written as a reusable bash script, that you can easily port to your infrastructure. Just download [upload_bom.sh](https://github.com/Weichwerke-Heidrich-Software/upload-bom-action/blob/main/upload_bom.sh) to your pipeline system and call it there:
```bash
if [ ! -f ./upload_bom.sh ]; then
    curl https://raw.githubusercontent.com/Weichwerke-Heidrich-Software/upload-bom-action/refs/heads/main/upload_bom.sh > ./upload_bom.sh
    chmod +x ./upload_bom.sh
fi
./upload_bom.sh <bom.cdx.json> <optional args...>
```

The script takes the same arguments as the action does, except that the bom argument is positional, and that optional arguments need to be prefixed with a double hyphen:
```
./upload_bom.sh ./bom.cdx.json --name <product-name> --version <product-version> --tlp amber
```

## Getting Started

### Prerequisites

This action requires `bomnipotent_client` or `bomnipotent_client.exe` to be available in PATH. The most straightforward way to achieve this in the pipeline is the [Setup BOMnipotent Client GitHub Action](https://github.com/marketplace/actions/setup-bomnipotent-client).

It also requires an instance of BOMnipotent Server, and the credentials for a [robot user](https://doc.bomnipotent.de/client/basics/account-creation/index.html#requesting-a-robot-account) with [BOM_MANAGEMENT](https://doc.bomnipotent.de/client/manager/access-management/permissions/index.html) permissions.

### Inputs

- `bom`: The filepath to the Bill of Materials (BOM) file to upload.
- `name`: *(Optional)* Overwrite the name of the BOM to upload. Can be either a string literal, or a path to a file containing the value.
- `version`: *(Optional)* Overwrite the version of the BOM to upload. Can be either a string literal, or a path to a file containing the value.
- `tlp`: *(Optional)* The Traffic Light Protocol (TLP) level of the BOM.
- `on-existing`: *(Optional)* What to do if a BOM with the same name and version already exists on the server. Options are: 'error' (default behaviour), 'skip' or 'replace'.

## Example Usage

```yaml

name: Example Workflow

on:
  push:
    tags:
      - 'v[0-9]+.[0-9]+.[0-9]+' # Trigger when a version tag is pushed.

jobs:
  install:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Create an SBOM using Syft (or any other tool that creates CycloneDX files)
        uses: anchore/sbom-action@v0
        with:
          file: './test_project/Cargo.lock'
          output-file: './sbom.cdx.json'
          format: 'cyclonedx-json'
          upload-artifact: 'false'

      - name: Setup BOMnipotent Client
        uses: Weichwerke-Heidrich-Software/setup-bomnipotent-action@v1
        with:
          domain: 'https://bomnipotent.<target-domain>'
          user: 'CI-CD@<your-domain>'
          secret-key: ${{ secrets.CLIENT_SECRET_KEY }} # You need to set this up in your action repository secrets.

      - name: Upload SBOM
        uses: Weichwerke-Heidrich-Software/upload-bom-action@v0
        with:
          bom: './sbom.cdx.json'
          name: '${{ github.event.repository.name }}' # If you want to use the repository name.
          version: '${{ github.ref_name }}' # Use the triggering tag as the version.
          # version: './version.txt' # The input can instead also be a filename.
          tlp: 'amber'
          on-existing: 'error'
```

## License

This project is licensed under the MIT License. See the [LICENSE file](https://github.com/Weichwerke-Heidrich-Software/upload-bom-action/blob/main/LICENSE) for details.
