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
export SAXON_JAR_URL=http://lux15.mpi.nl/nexus/service/local/repositories/central/content/net/sf/saxon/Saxon-HE/9.5.1-8/Saxon-HE-9.5.1-8.jar
export SAXON_JAR=/tmp/saxon.jar

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

	echo $FILENAME "->" $TARGET > /dev/stderr
	java -cp ${SAXON_JAR} net.sf.saxon.Transform ${IN_FILE} ${STYLESHEET} > ${TARGET}
}
export -f convert_to_imdi

# Get latest stylesheet
echo Retrieving CMDI2IMDI stylesheet... > /dev/stderr
git clone ${STYLESHEET_URL} ${STYLESHEET_DIR}

#Get saxon
if [ ! -f $SAXON_JAR ]
then
	echo Retrieving saxon > /dev/stderr
	wget -q -O ${SAXON_JAR} ${SAXON_JAR_URL}
fi

# Run conversion
if [ -d "$OUTPUT_DIR" ]
then
	echo Output directory \"${OUTPUT_DIR}\" already exists > /dev/stderr
else
	echo Transforming into $OUTPUT_DIR > /dev/stderr
	for DIR in `find $@ -type d`; do
		TARGET_DIR=${OUTPUT_DIR}/${DIR}
		echo Converting $DIR to $TARGET_DIR > /dev/stderr
		mkdir -p $TARGET_DIR
		java -cp ${SAXON_JAR} net.sf.saxon.Transform -s:${DIR} -xsl:${STYLESHEET} -o:${TARGET_DIR}
		rename -s .cmdi.xml .imdi ${TARGET_DIR}/*
	done
fi

echo Removing CMDI2IMDI stylesheet... > /dev/stderr
rm -rf ${STYLESHEET_DIR}

