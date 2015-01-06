#!/bin/sh
#
# Author: twan.goosen@mpi.nl
# Date: 6 January 2015
#
# Script that batch converts CMDIs to IMDI using the cmdi2imdi stylesheet from the
# metadata translator
#
# Add the set of files to be converted as parameters to this script. The directory
# structure will be matched in the output directory. All "{NAME}.cmdi" files will be
# renamed to "{NAME}.imdi".
#
# There are no command line options, any configuration should be done in this file.
#
# 

# Where to output the IMDIs
OUTPUT_DIR=imdi-out

# Location of Saxon-HE 9 JAR
SAXON_JAR=/Users/twan/.m2/repository/net/sf/saxon/Saxon-HE/9.5.1-8/Saxon-HE-9.5.1-8.jar

# CMDI-IMDI stylesheet location
STYLESHEET=/Users/twan/git/MetadataTranslator/Translator/src/main/resources/templates/cmdi2imdi/cmdi2imdiMaster.xslt

if [ -d "$OUTPUT_DIR" ]
then
	echo Output directory \"${OUTPUT_DIR}\" already exists
else
	for IN_FILE in $@
	do
		DIRNAME=$(dirname $IN_FILE)
		FILENAME=$(basename $IN_FILE)

		TARGET_DIR=${OUTPUT_DIR}/${DIRNAME}
		mkdir -p $TARGET_DIR

		TARGET_FILE=`echo ${FILENAME}|sed -e 's/\.cmdi$/.imdi/g'`
		TARGET=${TARGET_DIR}/${TARGET_FILE}

		echo $FILENAME "->" $TARGET
		java -cp ${SAXON_JAR} net.sf.saxon.Transform ${IN_FILE} ${STYLESHEET} > ${TARGET}
	done
fi
