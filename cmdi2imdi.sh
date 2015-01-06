#!/bin/sh
OUTPUT_DIR=imdi-out
SAXON_JAR=/Users/twan/.m2/repository/net/sf/saxon/Saxon-HE/9.5.1-8/Saxon-HE-9.5.1-8.jar
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
