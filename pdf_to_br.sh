#!/bin/bash
# Generator of books for the IABR-based reader.
#
# (c) Nik Sultana, Open Book Publishers, May 2015
# This software is distributed under the terms of the AGPLv3 -- see LICENSE.
#
# Expects the following to be set in the environment:
#   PDF_METADATA_SCRIPT
#   PDF_NUMOFPAGES_SCRIPT
#
# FIXME use JPG or PNG for leafs?
# FIXME check if IABR_TEMPLATE exists and contains the right files

set -eu
SHOW_CONFIG=false

# Leaf-generation parameters (default values)
DENSITY=200
WIDTH=800
HEIGHT=1200

# This will be renamed from having a ".template" extension to ".js"
MAIN_FILE=BookReaderJSSimple
# General parameters for the IABR template
# FIXME could make these into parameters
#EXTRA_PAGE=true
#DEFAULT_2PAGE_MODE=true
LINK_METADATA_FILE=linkmetadata.json

# The following variables will be picked out of the environment.
[ -z "${IABR_PARAM_LOGO_URL}" ] && \
  { echo "Need value for IABR_PARAM_LOGO_URL"; exit 1; }

#This directory is not specific to this book -- used by the template.
[ -z "${IABR_PARAM_BOOK_IMG_DIRECTORY}" ] && \
  { echo "Need value for IABR_PARAM_BOOK_IMG_DIRECTORY"; exit 1; }

# The URL of the reader instance that is being generated
[ -z "${IABR_PARAM_OUTPUT_BOOK_BASE_URL}" ] && \
  { echo "Need value for IABR_PARAM_OUTPUT_BOOK_BASE_URL"; exit 1; }

# Where this reader instances files (linkmetadata and images) will be located
[ -z "${IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL}" ] && \
  { echo "Need value for IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL"; exit 1; }

# Structure of the target directory
LEAFS_SUBDIR=page_leafs
LEAFS_FILENAME_PREFIX="leaf"

METADATA_FILENAME="linkmetadata.json"

while getopts "t:u:d:co:i:w:h:r:p:b:" OPT
do
  case "$OPT" in
    b)
      BOOK_TITLE="$OPTARG"
      ;;
    u)
      BOOK_URL="$OPTARG"
      ;;
    d)
      BOOK_DESCRIPTION="$OPTARG"
      ;;
    c)
      # Show config and exit
      SHOW_CONFIG=true
      ;;
    i)
      PDF_FILE_PATH="$OPTARG"
      ;;
    o)
      # For TARGET_DIR could us ISBN
      TARGET_DIR="$OPTARG"
      ;;
    r)
      DENSITY="$OPTARG"
      ;;
    w)
      WIDTH="$OPTARG"
      ;;
    h)
      HEIGHT="$OPTARG"
      ;;
    t)
      IABR_TEMPLATE="$OPTARG"
      ;;
  esac
done

shift $(($OPTIND - 1))
[ "$#" -ne 0 ] && { echo "Unrecognised parameter: $*"; exit 1; }

# PDF metadata scripts
[ -z "${PDF_METADATA_SCRIPT}" ] && { echo "Need value for PDF_METADATA_SCRIPT"; exit 1; }
[ -z "${PDF_NUMOFPAGES_SCRIPT}" ] && { echo "Need value for PDF_NUMOFPAGES_SCRIPT"; exit 1; }

[ -z "${IABR_TEMPLATE}" ] && { echo "Need value for IABR_TEMPLATE"; exit 1;}

## Book-specific parameter values for the IABR template
if [[ -z "${BOOK_TITLE}" || -z "${BOOK_URL}" || -z "${BOOK_DESCRIPTION}" ]]
then
  echo "Missing book parameter: title, or product page URL, or description."
  exit 1
fi


PDF_PATH=$(dirname ${PDF_FILE_PATH})
PDF_FILE=$(basename ${PDF_FILE_PATH})

GEOMETRY=${WIDTH}x${HEIGHT}

if [ ! -f ${PDF_FILE_PATH} ]
then
  echo "Couldn't find file: ${PDF_FILE_PATH}"
  exit 1
fi

if [ -d ${TARGET_DIR} ]
then
  echo "Target directory already exists"
  exit 1
fi

show-config () {
  echo -e "\n# Script dependencies"
  echo "PDF_METADATA_SCRIPT=${PDF_METADATA_SCRIPT}"
  echo "PDF_NUMOFPAGES_SCRIPT=${PDF_NUMOFPAGES_SCRIPT}"

  echo -e "\n# PDF file to base the book on"
  echo "PDF_FILE_PATH=${PDF_FILE_PATH}"
  echo "PDF_PATH=${PDF_PATH}"
  echo "PDF_FILE=${PDF_FILE}"

  echo -e \n"# Target"
  echo "TARGET_DIR=${TARGET_DIR}"

  echo -e "\n# Leaf-generation parameters"
  echo "DENSITY=${DENSITY}"
  echo "WIDTH=${WIDTH}"
  echo "HEIGHT=${HEIGHT}"
  echo "GEOMETRY=${GEOMETRY}"

  echo -e "\n# General parameters for the IABR template"
  echo "IABR_TEMPLATE=${IABR_TEMPLATE}"
  echo "EXTRA_PAGE=${EXTRA_PAGE}"
  echo "DEFAULT_2PAGE_MODE=${DEFAULT_2PAGE_MODE}"

  echo -e "\n# Book-specific parameter values for the IABR template"
  echo "BOOK_TITLE=${BOOK_TITLE}"
  echo "BOOK_URL=${BOOK_URL}"
  echo "BOOK_DESCRIPTION=${BOOK_DESCRIPTION}"

  echo -e "\n"
  echo "IABR_PARAM_LOGO_URL=${IABR_PARAM_LOGO_URL}"
  echo "IABR_PARAM_BOOK_IMG_DIRECTORY=${IABR_PARAM_BOOK_IMG_DIRECTORY}"
  echo "IABR_PARAM_OUTPUT_BOOK_BASE_URL=${IABR_PARAM_OUTPUT_BOOK_BASE_URL}"
  echo "IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL=${IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL}"

  echo -e "\n# Structure of the target directory"
  echo "LEAFS_SUBDIR=${LEAFS_SUBDIR}"
  echo "LEAFS_FILENAME_PREFIX=${LEAFS_FILENAME_PREFIX}"
  echo "METADATA_FILENAME=${METADATA_FILENAME}"
}

if [ "${SHOW_CONFIG}" = true ]
then
  show-config
  exit 0;
fi

echo -e "\nCreating target directory: ${TARGET_DIR}"
mkdir ${TARGET_DIR}
cd ${TARGET_DIR}

echo -e "\nCounting pages ..."
NUM_PAGES=$(${PDF_NUMOFPAGES_SCRIPT} ${PDF_FILE_PATH})
echo -e "\nNumber of pages in the PDF file: ${NUM_PAGES}"

generate-link-metadata () {
  echo -e "\nGenerating link metadata: ${LINK_METADATA_FILE}"
  eval ${PDF_METADATA_SCRIPT} ${PDF_FILE_PATH} > ${LINK_METADATA_FILE}
  echo -e "\nLink metadata generation complete."
}

generate-leaves () {
  mkdir ${LEAFS_SUBDIR}
  cd ${LEAFS_SUBDIR}
  echo -e "\nGenerating page leafs: ${LEAFS_SUBDIR}/${LEAFS_FILENAME_PREFIX}*"
  # from http://blog.tomayac.com/index.php?date=2013-09-16
  convert -density ${DENSITY} "${PDF_FILE_PATH}" "${LEAFS_FILENAME_PREFIX}".jpg

  for i in $(ls *.jpg); do convert "$i" -geometry ${GEOMETRY} "$i"; done

  cd ..
}

specify-iabr-details () {
  echo -e "\nInstantiating the IABR template from ${IABR_TEMPLATE}"
  cp -r ${IABR_TEMPLATE}/* .

  perl -pe "s/IABR_PARAM_LOGO_URL/${IABR_PARAM_LOGO_URL}/" ${MAIN_FILE}.template \
  | perl -pe "s/IABR_PARAM_WIDTH/${WIDTH}/" \
  | perl -pe "s/IABR_PARAM_HEIGHT/${HEIGHT}/" \
  | perl -pe "s/IABR_PARAM_NUM_PAGES/${NUM_PAGES}/" \
  | perl -pe "s/IABR_PARAM_BOOK_TITLE/${BOOK_TITLE}/" \
  | perl -pe "s/IABR_PARAM_BOOK_URL/${BOOK_URL}/" \
  | perl -pe "s/IABR_PARAM_BOOK_DESCRIPTION/${BOOK_DESCRIPTION}/" \
  | perl -pe "s/IABR_PARAM_LEAFS_SUBDIR/${LEAFS_SUBDIR}/" \
  | perl -pe "s/IABR_PARAM_LEAFS_FILENAME_PREFIX/${LEAFS_FILENAME_PREFIX}/" \
  | perl -pe "s/IABR_PARAM_METADATA_FILENAME/${METADATA_FILENAME}/" \
  | perl -pe "s/IABR_PARAM_OUTPUT_BOOK_BASE_URL/${IABR_PARAM_OUTPUT_BOOK_BASE_URL}/" \
  | perl -pe "s/IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL/${IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL}/" \
  | perl -pe "s/IABR_PARAM_BOOK_IMG_DIRECTORY/${IABR_PARAM_BOOK_IMG_DIRECTORY}/" \
  > ${MAIN_FILE}.js
}

# Don't run this in background any more
generate-link-metadata

generate-leaves

specify-iabr-details

echo -e "\nFinished generating book for ${BOOK_TITLE}"
