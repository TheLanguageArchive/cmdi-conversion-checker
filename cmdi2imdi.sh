#!/bin/bash
#
# Author: twan.goosen@mpi.nl
# Date: 15 January 2015
#
# Script that batch converts CMDIs to IMDI using the cmdi2imdi stylesheet from the
# metadata translator
#
# Add the directories to be converted as parameters to this script. The directory
# structure will be matched in the output directory. All "{NAME}.cmdi" files will be
# renamed to "{NAME}.imdi".
#
# There are no command line options, any configuration should be done in this file.
#
# 

# Location of Saxon-HE 9 JAR
export SAXON_JAR=~/.m2/repository/net/sf/saxon/Saxon-HE/9.5.1-8/Saxon-HE-9.5.1-8.jar

# Location of cmdi2imdi stylesheet
export STYLESHEET_URL=https://github.com/TheLanguageArchive/MetadataTranslator.git

# Where to output the IMDIs
export OUTPUT_DIR=imdi-out

# CMDI-IMDI stylesheet location
export STYLESHEET_DIR=/tmp/cmdi2imdi-`date +"%s"`
export STYLESHEET=${STYLESHEET_DIR}/Translator/src/main/resources/templates/cmdi2imdi/cmdi2imdiMaster.xslt

function convert_to_imdi {
	IN_FILE=$1
	DIRNAME=$(dirname $IN_FILE)
	FILENAME=$(basename $IN_FILE)

	TARGET_DIR=${OUTPUT_DIR}/${DIRNAME}
	mkdir -p $TARGET_DIR

	TARGET_FILE=`echo ${FILENAME}|sed -e 's/\.cmdi$/.imdi/g'`
	TARGET=${TARGET_DIR}/${TARGET_FILE}

	echo $FILENAME "->" $TARGET
	java -cp ${SAXON_JAR} net.sf.saxon.Transform ${IN_FILE} ${STYLESHEET} > ${TARGET}
}
export -f convert_to_imdi

# Get latest stylesheet
echo Retrieving CMDI2IMDI stylesheet...
git clone ${STYLESHEET_URL} ${STYLESHEET_DIR}

# Run conversion
if [ -d "$OUTPUT_DIR" ]
then
	echo Output directory \"${OUTPUT_DIR}\" already exists
else
	find $@ -name "*.cmdi" -exec bash -c "convert_to_imdi {}" \;
fi
