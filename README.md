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
./upload_bom <args...>
```

## Getting Started

### Prerequisites

This action requires `bomnipotent_client` or `bomnipotent_client.exe` to be available in PATH. The most straightforward way to achieve this in the pipeline is the [Setup BOMnipotent Client GitHub Action](https://github.com/marketplace/actions/setup-bomnipotent-client).

### Inputs

- `bom`: The filepath to the Bill of Materials (BOM) file to upload.
- `name`: *(Optional)* Overwrite the name of the BOM to upload.
- `version`: *(Optional)* Overwrite the version of the BOM to upload.
- `tlp`: *(Optional)* The Traffic Light Protocol (TLP) level of the BOM.
- `on-existing`: *(Optional)* What to do if a BOM with the same name and version already exists on the server. Options are: 'error' (default behaviour), 'skip' or 'replace'.

## Example Usage

```yaml

name: Example Workflow

on: [push]

jobs:
  install:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Create an SBOM using Syft
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
          name: 'Test'
          version: '1.0.0'
          tlp: 'amber'
          on-existing: 'error'
```

## License

This project is licensed under the MIT License. See the [LICENSE file](https://github.com/Weichwerke-Heidrich-Software/upload-bom-action/blob/main/LICENSE) for details.
