#!/bin/sh
CDM=$0
CDMDIR=`dirname "$CDM"`
if [ -z $1 ] ; then
	echo "You must specify an input file!"
	exit 1
fi
if [ $CDMDIR=. ] ; then
	CDMDIR=`pwd`
fi

if [ -z "$JAVA_HOME" ] ; then
	JAVA_HOME=/usr
fi

SAXON_JAR="$CDMDIR/saxon9.jar"
OUTPUT_DIR="$PWD/output"
STYLESHEET="$CDMDIR/cdm.xsl"

${JAVA_HOME}/bin/java -jar "${SAXON_JAR}" $1 "${STYLESHEET}" "outputdir=${OUTPUT_DIR}"
