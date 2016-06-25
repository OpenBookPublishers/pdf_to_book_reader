#!/bin/bash
# Wrapper script for the generator of books for the IABR-based reader.
#
# (c) Nik Sultana, Open Book Publishers, May 2015
# This software is distributed under the terms of the AGPLv3 -- see LICENSE.


while getopts "b:u:d:s:t:i:o:l:e:f:r:m:n:" OPT
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
#    c)
#      PRODUCT_ID="$OPTARG"
#      ;;
    s)
      GENERATOR_SCRIPT="$OPTARG"
      ;;

    t)
      IABR_TEMPLATE="$OPTARG"
      ;;
    i)
      PDF_FILE_PATH="$OPTARG"
      ;;
    o)
      TARGET_DIR="$OPTARG"
      ;;

    l)
      IABR_PARAM_LOGO_URL="$OPTARG"
      ;;
    e)
      IABR_PARAM_BOOK_IMG_DIRECTORY="$OPTARG"
      ;;
    f)
      IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL="$OPTARG"
      ;;
    r)
      IABR_PARAM_OUTPUT_BOOK_BASE_URL="$OPTARG"
      ;;

    m)
      PDF_METADATA_SCRIPT="$OPTARG"
      ;;
    n)
      PDF_NUMOFPAGES_SCRIPT="$OPTARG"
      ;;
  esac
done

shift $(($OPTIND - 1))
[ "$#" -ne 0 ] && { echo "Unrecognised parameter: $*"; exit 1; }

#[ -z "${PRODUCT_ID}" ] && { echo "Need value for PRODUCT_ID"; exit 1; }
[ -z "${BOOK_TITLE}" ] && { echo "Need value for BOOK_TITLE"; exit 1; }
[ -z "${BOOK_URL}" ] && { echo "Need value for BOOK_URL"; exit 1; }
[ -z "${BOOK_DESCRIPTION}" ] && { echo "Need value for BOOK_DESCRIPTION"; exit 1; }
[ -z "${GENERATOR_SCRIPT}" ] && { echo "Need value for GENERATOR_SCRIPT"; exit 1; }

#export IABR_PARAM_LOGO_URL="http://www.openbookpublishers.com"
#export IABR_PARAM_BOOK_IMG_DIRECTORY="http://www.openbookpublishers.com/bookreader/BookReader/images/"
#export IABR_PARAM_OUTPUT_BOOK_BASE_URL="http://www.openbookpublishers.com/reader/${PRODUCT_ID}"
#export IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL="http://www.openbookpublishers.com/bookreader/${PRODUCT_ID}/"

export IABR_PARAM_LOGO_URL
export IABR_PARAM_BOOK_IMG_DIRECTORY
export IABR_PARAM_OUTPUT_BOOK_FILES_BASE_URL
export IABR_PARAM_OUTPUT_BOOK_BASE_URL

export PDF_METADATA_SCRIPT
export PDF_NUMOFPAGES_SCRIPT

${GENERATOR_SCRIPT} \
  -b "${BOOK_TITLE}" \
  -u "${BOOK_URL}" \
  -d "${BOOK_DESCRIPTION}" \
  -i "${PDF_FILE_PATH}" \
  -o "${TARGET_DIR}" \
  -t "${IABR_TEMPLATE}"
