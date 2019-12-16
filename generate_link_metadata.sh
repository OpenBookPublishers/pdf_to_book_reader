#!/bin/bash

set -eu

PDF_FILE_PATH=$1
prod_id=$2

cd output/$prod_id

LINK_METADATA_FILE=linkmetadata.json
PDF_METADATA_SCRIPT="python ../../PDF-Mine/pdf_metadata.py"

echo -e "\nGenerating link metadata: ${LINK_METADATA_FILE}"
TMP=$(tempfile)
eval ${PDF_METADATA_SCRIPT} ${PDF_FILE_PATH} > $TMP
cp $TMP ${LINK_METADATA_FILE}
rm -f -- $TMP
echo -e "\nLink metadata generation complete."

