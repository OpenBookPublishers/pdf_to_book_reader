#!/bin/bash

set -eu

PDF_FILE_PATH=$1
prod_id=$2

cd output/$prod_id

# Structure of the target directory
LEAFS_SUBDIR=page_leafs
LEAFS_FILENAME_PREFIX="leaf"
DENSITY=200
WIDTH=800
HEIGHT=1200
GEOMETRY=${WIDTH}x${HEIGHT}

generate-leaves () {
  mkdir -p ${LEAFS_SUBDIR}
  cd ${LEAFS_SUBDIR}
  echo -e "\nGenerating page leafs: ${LEAFS_SUBDIR}/${LEAFS_FILENAME_PREFIX}*"
  # from http://blog.tomayac.com/index.php?date=2013-09-16
  convert -density ${DENSITY} "${PDF_FILE_PATH}" "${LEAFS_FILENAME_PREFIX}".jpg

  for i in $(ls *.jpg); do convert "$i" -geometry ${GEOMETRY} "$i"; done

  cd ..
  touch leaves.stamp
}

generate-leaves
