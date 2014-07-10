<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:NMLEX="http://www.shef.ac.uk/SpineMLExperimentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- Note that the param is outside the template, but is used inside the template. -->
<xsl:param name="hostos" select="'unknown'" />

<xsl:template match="/">
<!-- THIS IS A NON-PLATFORM SPECIFIC XSLT SCRIPT THAT GENERATES THE SIMPLE SCRIPT TO CREATE
     THE PROCESSES / SYSTEM -->
<!-- VERSION = LINUX OR OSX -->

<!-- To produce output for either Linux32/64 or Mac OS, we use a parameter, passed in,
     called hostos which is used to set the compiler flags, include paths and linker flags,
     as applicable. -->
<xsl:variable name="compiler_flags">
    <xsl:if test="$hostos='Linux32' or $hostos='Linux64'">-fPIC -Werror -pthread -O3 -ffast-math -shared -D__GLN__</xsl:if>
    <xsl:if test="$hostos='OSX'">-fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -O3 -ffast-math  -dynamiclib -arch i386 -D__OSX__</xsl:if>
</xsl:variable>

<xsl:variable name="linker_flags">
    <xsl:if test="$hostos='OSX'">-L"$SYSTEMML_INSTALL_PATH/BRAHMS/bin" -lbrahms-engine</xsl:if>
</xsl:variable>

<xsl:variable name="component_output_file">
    <xsl:if test="$hostos='Linux32' or $hostos='Linux64'">component.so</xsl:if>
    <xsl:if test="$hostos='OSX'">component.dylib</xsl:if>
</xsl:variable>

<xsl:variable name="platform_specific_includes">
    <xsl:if test="$hostos='Linux32' or $hostos='Linux64'">-I/usr/include/brahms -I/var/lib/brahms/Namespace</xsl:if>
</xsl:variable>

<!-- since we start in the experiment file we need to use for-each to get to the model file -->
<xsl:variable name="model_xml" select="//NMLEX:Model/@network_layer_url"/>
<xsl:for-each select="document(//NMLEX:Model/@network_layer_url)">

<xsl:choose>

<!-- SpineML low level network layer: START SMLLOWNL SECTION -->
<xsl:when test="SMLLOWNL:SpineML">#!/bin/bash
REBUILD_COMPONENTS=$1
REBUILD_SYSTEMML=$2
MODEL_DIR=$3
INPUT=$4 # always experiment.xml.
BRAHMS_NS=$5
SPINEML_2_BRAHMS_DIR=$6
OUTPUT_DIR=$7 # The directory in which to generate output script and produce actual output.
XSL_SCRIPT_PATH=$8

# Working directory - need to pass this to xsl scripts as we no longer have them inside the current working tree.
echo "SPINEML_2_BRAHMS_DIR is $SPINEML_2_BRAHMS_DIR"

# A note about Namespaces
#
# A Brahms installation will exist along with a SpineML_2_BRAHMS installation.
# Each installation may have its own namespace, and these are referred to here
# as BRAHMS_NS and SPINEML_2_BRAHMS_NS.
#
# All SpineML_2_BRAHMS components are compiled and held in the SPINEML_2_BRAHMS_NS
# The BRAHMS_NS contains the Brahms components, as distributed either as the Debian
# package or the Brahms binary package. Both namespaces are passed to the brahms call.
#
SPINEML_2_BRAHMS_NS=$SPINEML_2_BRAHMS_DIR/Namespace
echo "SPINEML_2_BRAHMS_NS is $SPINEML_2_BRAHMS_NS"
echo "BRAHMS_NS is $BRAHMS_NS"

DEBUG="false"

DBG_FLAG=""
if [ $DEBUG = "true" ]; then
# Add -g to compiler flags
DBG_FLAG="-g"
REBUILD_COMPONENTS="true"
fi

# Set up the include path for rng.h and impulse.h
if [ -f /usr/include/spineml-2-brahms/rng.h ]; then
    # In this case, it looks like the user has the debian package
    SPINEML_2_BRAHMS_INCLUDE_PATH=/usr/include/spineml-2-brahms
else
    # Use a path relative to SPINEML_2_BRAHMS_DIR
    SPINEML_2_BRAHMS_INCLUDE_PATH=$SPINEML_2_BRAHMS_DIR/include
fi
echo "SPINEML_2_BRAHMS_INCLUDE_PATH=$SPINEML_2_BRAHMS_INCLUDE_PATH"

# Set up the path to the "tools" directory.

# exit on first error
#set -e
if [ "$REBUILD_COMPONENTS" = "true" ]; then
# clean up the temporary dirs - we don't want old component versions lying around!
rm -R $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/*  &amp;> /dev/null
fi
echo "Creating the Neuron populations..."
<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
<xsl:choose>
<xsl:when test="./SMLLOWNL:Neuron/@url = 'SpikeSource'">
echo "SpikeSource, skipping compile"
</xsl:when>
<xsl:otherwise>
<xsl:variable name="linked_file" select="document(./SMLLOWNL:Neuron/@url)"/>
<!-- Here we use the population number to determine which Neuron type we are outputting -->
<xsl:variable name="number"><xsl:number count="/SMLLOWNL:SpineML/SMLLOWNL:Population" format="1"/></xsl:variable>
echo "&lt;Number&gt;<xsl:value-of select="$number"/>&lt;/Number&gt;" &amp;&gt; counter.file

DIRNAME=$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0

diff -q $MODEL_DIR/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/> $DIRNAME/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/> &amp;> /dev/null
if [ $? == 0 ] &amp;&amp; [ -f $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/component.cpp ] &amp;&amp; [ -f $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/component.so ]; then
echo "Component for population <xsl:value-of select="$number"/> exists, skipping"
else
echo "Creating component.cpp for population <xsl:value-of select="$number"/> in directory $DIRNAME"
xsltproc -o $OUTPUT_DIR/component.cpp --stringparam spineml_output_dir $OUTPUT_DIR $XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_neurons.xsl $MODEL_DIR/<xsl:value-of select="$model_xml"/>

if [ ! -f component.cpp ]; then
echo "Error: no component.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_neurons.xsl and the model"
exit -1
fi
mkdir -p $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
cp $MODEL_DIR/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/> ./component.cpp $SPINEML_2_BRAHMS_INCLUDE_PATH/rng.h $SPINEML_2_BRAHMS_INCLUDE_PATH/impulse.h $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/release.xml

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;> $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/build

cd $SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
echo "Compiling component binary"
./build
cd - &amp;&gt; /dev/null
fi # The check if component exists

</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
echo "Creating the projections..."
<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
<!-- Here we use the population number to determine which pop the projection belongs to -->
<xsl:variable name="number1"><xsl:number count="/SMLLOWNL:SpineML/SMLLOWNL:Population" format="1"/></xsl:variable>
	<xsl:variable name="src" select="@name"/>
	<xsl:for-each select=".//SMLLOWNL:Projection">
<!-- Here we use the Synapse number to determine which pop the projection targets -->
<xsl:variable name="number2"><xsl:number count="//SMLLOWNL:Projection" format="1"/></xsl:variable>
                <xsl:variable name="dest" select="@dst_population"/>
		<xsl:for-each select=".//SMLLOWNL:Synapse">
<!-- Here we use the target number to determine which WeightUpdate the projection targets -->
<xsl:variable name="number3"><xsl:number count="//SMLLOWNL:Synapse" format="1"/></xsl:variable>
echo "&lt;Nums&gt;&lt;Number1&gt;<xsl:value-of select="$number1"/>&lt;/Number1&gt;&lt;Number2&gt;<xsl:value-of select="$number2"/>&lt;/Number2&gt;&lt;Number3&gt;<xsl:value-of select="$number3"/>&lt;/Number3&gt;&lt;/Nums&gt;" &amp;&gt; counter.file

<xsl:variable name="linked_file" select="document(SMLLOWNL:WeightUpdate/@url)"/>
<xsl:variable name="linked_file2" select="document(SMLLOWNL:PostSynapse/@url)"/>
<xsl:variable name="wu_url" select="SMLLOWNL:WeightUpdate/@url"/>
<xsl:variable name="ps_url" select="SMLLOWNL:PostSynapse/@url"/>
DIRNAME=$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/WU/<xsl:value-of select="local-name(SMLNL:ConnectionList)"/><xsl:value-of select="local-name(SMLNL:FixedProbabilityConnection)"/><xsl:value-of select="local-name(SMLNL:AllToAllConnection)"/><xsl:value-of select="local-name(SMLNL:OneToOneConnection)"/><xsl:value-of select="translate(document(SMLLOWNL:WeightUpdate/@url)//SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
diff -q $MODEL_DIR/<xsl:value-of select="$wu_url"/> $DIRNAME/<xsl:value-of select="$wu_url"/> &amp;> /dev/null
if [ $? == 0 ] &amp;&amp; [ -f component.cpp ]; then
LA="moo"
#echo "Weight Update component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping"
else
echo "Building weight update component.cpp for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> in directory $DIRNAME"
xsltproc -o $OUTPUT_DIR/component.cpp --stringparam spineml_model_dir $MODEL_DIR --stringparam spineml_output_dir $OUTPUT_DIR $XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_weight.xsl $MODEL_DIR/<xsl:value-of select="$model_xml"/>
if [ ! -f component.cpp ]; then
echo "Error: no component.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_weight.xsl and the model"
exit -1
fi
mkdir -p $DIRNAME
cp $MODEL_DIR/<xsl:value-of select="$wu_url"/> ./component.cpp $SPINEML_2_BRAHMS_INCLUDE_PATH/rng.h $SPINEML_2_BRAHMS_INCLUDE_PATH/impulse.h $DIRNAME/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $DIRNAME/release.xml

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;> $DIRNAME/build

cd $DIRNAME/

echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi

DIRNAME=$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/PS/<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass"><xsl:value-of select="translate(@name,' -', 'oH')"/>
</xsl:for-each>/brahms/0
diff -q $MODEL_DIR/<xsl:value-of select="$ps_url"/> $DIRNAME/<xsl:value-of select="$ps_url"/> &amp;> /dev/null
if [ $? == 0 ] &amp;&amp; [ -f component.cpp ]; then
LA="moo"
#echo "PostSynapse component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping"
else
echo "Building postsynapse component.cpp for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> in directory $DIRNAME"
xsltproc -o $OUTPUT_DIR/component.cpp --stringparam spineml_output_dir $OUTPUT_DIR $XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_postsyn.xsl $MODEL_DIR/<xsl:value-of select="$model_xml"/>
if [ ! -f component.cpp ]; then
echo "Error: no component.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_postsyn.xsl and the model"
exit -1
fi
mkdir -p $DIRNAME
cp $MODEL_DIR/<xsl:value-of select="$ps_url"/> ./component.cpp $SPINEML_2_BRAHMS_INCLUDE_PATH/rng.h $SPINEML_2_BRAHMS_INCLUDE_PATH/impulse.h $DIRNAME/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $DIRNAME/release.xml

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;> $DIRNAME/build

cd $DIRNAME/
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi
<!-- MORE HERE -->

		</xsl:for-each>
	</xsl:for-each>
</xsl:for-each>
if [ "$REBUILD_SYSTEMML" = "true" ] || [ ! -f $OUTPUT_DIR/sys.xml ] ; then
echo "Building the SystemML system..."
xsltproc -o $OUTPUT_DIR/sys.xml --stringparam spineml_model_dir $MODEL_DIR $XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_NL.xsl $MODEL_DIR/$INPUT
else
echo "Re-using the SystemML system."
fi
if [ "$REBUILD_SYSTEMML" = "true" ] || [ ! -f $OUTPUT_DIR/sys-exe.xml ] ; then
echo "Building the SystemML execution..."
xsltproc -o $OUTPUT_DIR/sys-exe.xml $XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_EXPT.xsl $MODEL_DIR/$INPUT
else
echo "Re-using the SystemML execution."
fi
echo "Done!"

# run!
echo "Executing: brahms --par-NamespaceRoots=$BRAHMS_NS:$SPINEML_2_BRAHMS_NS:$SPINEML_2_BRAHMS_DIR/tools $OUTPUT_DIR/sys-exe.xml"
brahms --par-NamespaceRoots=$BRAHMS_NS:$SPINEML_2_BRAHMS_NS:$SPINEML_2_BRAHMS_DIR/tools $OUTPUT_DIR/sys-exe.xml

</xsl:when> <!-- END SMLLOWNL SECTION -->

<!-- SpineML high level network layer -->
<!-- FIXME: Need to reproduce the script above for SMLLOWNL here, with SMLLOWNL replaced by SMLNL: -->
<xsl:when test="SMLNL:SpineML">#/bin/bash
echo "Duplicate code for the SMLLOWNL case from START SMLLOWNL SECTION to END SMLLOWNL SECTION."
exit 1
</xsl:when>
<xsl:otherwise>
echo "ERROR: Unrecognised SpineML Network Layer file";
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>


