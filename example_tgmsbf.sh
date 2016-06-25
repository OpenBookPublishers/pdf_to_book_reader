#!/bin/bash
# Example showing the use of the wrapper script for generating books for the
# IABR-based reader.
#
# (c) Nik Sultana, Open Book Publishers, May 2015
# This software is distributed under the terms of the AGPLv3 -- see LICENSE.


#PRODUCT_ID=3
#PDFFILE=../scribd_books/ThatGreeceMightStillBeFree.pdf
#BOOKNAME="That Greece Might Still Be Free"
#DESCRIPTION="William St Clair's meticulously researched and highly readable \
#account of their aspirations and experiences was hailed as definitive when it \
#was first published. Long out of print, it remains the standard account of the \
#Philhellenic movement and essential reading for any students of the Greek War of \
#Independence, Byron, and European Romanticism. Its relevance to more modern \
#ethnic and religious conflicts is becoming increasingly appreciated by scholars \
#worldwide."

while getopts "b:d:c:i:" OPT
do
  case "$OPT" in
    b)
      BOOK_TITLE="$OPTARG"
      ;;
    d)
      BOOK_DESCRIPTION="$OPTARG"
      ;;
    c)
      PRODUCT_ID="$OPTARG"
      ;;
    i)
      PDF_FILE_PATH="$OPTARG"
      ;;
  esac
done

shift $(($OPTIND - 1))
[ "$#" -ne 0 ] && { echo "Unrecognised parameter: $*"; exit 1; }

[ -z "${BOOK_TITLE}" ] && { echo "Need value for BOOK_TITLE"; exit 1; }
[ -z "${BOOK_DESCRIPTION}" ] && { echo "Need value for BOOK_DESCRIPTION"; exit 1; }
[ -z "${PRODUCT_ID}" ] && { echo "Need value for PRODUCT_ID"; exit 1; }
[ -z "${PDF_FILE_PATH}" ] && { echo "Need value for PDF_FILE_PATH"; exit 1; }

D=${PWD}

./wrapper.sh \
  -s "./pdf_to_br.sh" \
  -t "${D}/IABR_template" \
  -m "python ${D}/../my_fork/PDF-Mine/pdf_metadata.py" \
  -n "python ${D}/../my_fork/PDF-Mine/pdf_numofpages.py" \
  -b "${BOOK_TITLE}" \
  -d "${BOOK_DESCRIPTION}" \
  -i "${D}/${PDF_FILE_PATH}" \
  -o "${PRODUCT_ID}/" \
  -u "http:\/\/www.openbookpublishers.com\/product\/${PRODUCT_ID}\/" \
  -l "http:\/\/www.openbookpublishers.com" \
  -e "http:\/\/www.openbookpublishers.com\/bookreader\/BookReader\/images\/" \
  -f "http:\/\/www.openbookpublishers.com\/bookreader\/${PRODUCT_ID}\/" \
  -r "http:\/\/www.openbookpublishers.com\/reader\/${PRODUCT_ID}"
