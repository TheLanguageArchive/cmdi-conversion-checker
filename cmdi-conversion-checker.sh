#!/bin/bash
#
# Author: twan.goosen@mpi.nl
# Date: 15 January 2015
#
# Script that takes a hierarchy of IMDI records and a parallel hierarchy of converted CMDI
# records and validates the conversion by converting the CMDIs back to IMDI (using the
# stylesheets from the MetadataTranslator and comparing the originals with the conversion
# output by means of the ImdiDiff tool.
#
# Metadata Translator: <https://github.com/TheLanguageArchive/MetadataTranslator>
# IMDI Diff: <https://github.com/TheLanguageArchive/ImdiDiff>
#
# Parameters:
# 	1. Location of directory with original IMDIs
#	2. Location of CMDIs derived from this IMDI (same directory structure assumed)

# Set this to the jar-with-dependencies of the ImdiDiffer
# (obtain and build from <https://github.com/TheLanguageArchive/ImdiDiff> if needed)
IMDI_DIFF_JAR=~/git/ImdiDiff/target/ImdiDiff-1.0-SNAPSHOT-jar-with-dependencies.jar

# Location of cmdi2imdi stylesheet
STYLESHEET_URL=https://github.com/TheLanguageArchive/MetadataTranslator.git

# CMDI-IMDI stylesheet clone location
STYLESHEET_DIR=/tmp/cmdi2imdi-`date +"%s"`
STYLESHEET=${STYLESHEET_DIR}/Translator/src/main/resources/templates/cmdi2imdi/cmdi2imdiMaster.xslt

DIR=$(dirname ${BASH_SOURCE})
CMDI2IMDI=${DIR}/cmdi2imdi.sh
IMDI_OUTPUT_DIR=$DIR/imdi-out

ORIGINAL_IMDI_DIR=$1
CONVERTED_CMDI_DIR=$2

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <original-imdi-dir> <converted-cmdi-dir>" > /dev/stderr
    exit 1
fi

if [ ! -d "$ORIGINAL_IMDI_DIR" ]; then
	echo The directory \""$ORIGINAL_IMDI_DIR"\" does not exist > /dev/stderr
	exit 2
fi

if [ ! -d "$CONVERTED_CMDI_DIR" ]; then
	echo The directory \""$CONVERTED_CMDI_DIR"\" does not exist > /dev/stderr
	exit 3
fi

if [ ! -f "$IMDI_DIFF_JAR" ]; then
	echo The JAR file for the ImdiDiff tool could not be found at the specified location: \
			$IMDI_DIFF_JAR > /dev/stderr
	exit 4
fi

# ok to remove old output directory? 
if [ -d "$IMDI_OUTPUT_DIR" ]
then
	read -p "\"${IMDI_OUTPUT_DIR}\" already exists, ok to remove? (y/n)" -n 1 -r
	echo "" > /dev/stderr
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo "Removing $IMDI_OUTPUT_DIR..." > /dev/stderr
    	rm -rf $IMDI_OUTPUT_DIR
    else 
    	exit 5
	fi
fi

# Get latest stylesheet
echo ---------------------------------- > /dev/stderr
echo Retrieving CMDI2IMDI stylesheet... > /dev/stderr
echo ---------------------------------- > /dev/stderr
git clone ${STYLESHEET_URL} ${STYLESHEET_DIR}

# convert cmdi to imdi
echo --------------------------------- > /dev/stderr
echo Converting CMDI output to IMDI... > /dev/stderr
echo --------------------------------- > /dev/stderr

java -Dorg.slf4j.simpleLogger.logFile=System.err \
	 -cp ${IMDI_DIFF_JAR} \
	 nl.mpi.imdidiff.util.RecursiveTransformer \
	 	"${STYLESHEET}" "${CONVERTED_CMDI_DIR}" "${IMDI_OUTPUT_DIR}" .cmdi .imdi

# run checker
echo ------------------ > /dev/stderr
echo Performing diff... > /dev/stderr
echo ------------------ > /dev/stderr
echo Outputting to stdout... > /dev/stderr
java -Dorg.slf4j.simpleLogger.logFile=System.out \
	 -jar ${IMDI_DIFF_JAR} \
	 	${ORIGINAL_IMDI_DIR} ${IMDI_OUTPUT_DIR}
