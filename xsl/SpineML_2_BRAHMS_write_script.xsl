<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:NMLEX="http://www.shef.ac.uk/SpineMLExperimentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- Note that the param is outside the template, but is used inside the template. -->
<xsl:param name="hostos" select="'unknown'" />

<xsl:template match="/">
<!-- THIS IS A NON-PLATFORM SPECIFIC XSLT SCRIPT THAT GENERATES THE BASH SCRIPT TO CREATE
     THE PROCESSES / SYSTEM -->
<!-- VERSION = LINUX OR OSX -->

<!-- To produce output for either Linux32/64 or Mac OS, we use a parameter, passed in,
     called hostos which is used to set the compiler flags, include paths and linker flags,
     as applicable. -->
<xsl:variable name="compiler_flags">
    <xsl:if test="$hostos='Linux32' or $hostos='Linux64'">-fPIC -Werror -pthread -O3 -shared -D__GLN__</xsl:if>
    <xsl:if test="$hostos='OSX'">-fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -O3 -dynamiclib -arch i386 -D__OSX__</xsl:if>
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
MODEL_DIR=$3 <!-- The model to work from. Probably equal to $OUTPUT_DIR_BASE/model -->
INPUT=$4 <!-- always experiment.xml -->
BRAHMS_NS=$5
SPINEML_2_BRAHMS_DIR=$6
OUTPUT_DIR_BASE=$7 <!-- The directory in which to generate output script and produce actual output. -->
XSL_SCRIPT_PATH=$8
VERBOSE_BRAHMS=${9}
NODES=${10} <!-- Number of machine nodes to use. If >1, then this assumes we're using Sun Grid Engine. -->
NODEARCH=${11}

echo "VERBOSE_BRAHMS: $VERBOSE_BRAHMS"
echo "NODES: $NODES"
echo "NODEARCH: $NODEARCH"

if [ "x$VERBOSE_BRAHMS" = "xno" ]; then
  VERBOSE_BRAHMS=""
fi

if [ "x$NODES" = "x" ]; then
  NODES=0
fi

<!-- Is user requesting specific architecture? -->
if [ "x$NODEARCH" = "xamd" ]; then
  NODEARCH="-l arch=amd*"
elif [ "x$NODEARCH" = "xintel" ]; then
  NODEARCH="-l arch=intel*"
else
  echo "Ignoring invalid node architecture '$NODEARCH'"
  NODEARCH=""
fi

<!-- Are we in Sun Grid Engine mode? -->
if [[ "$NODES" -gt 0 ]]; then
  echo "Submitting execution Sun Grid Engine with $NODES nodes."
fi

<!-- Working directory - need to pass this to xsl scripts as we no
     longer have them inside the current working tree. -->
echo "SPINEML_2_BRAHMS_DIR is $SPINEML_2_BRAHMS_DIR"

<!-- Some paths need to be URL encoded. -->
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos&lt;strlen ; pos++ )); do
     c=${string:$pos:1}
     case "$c" in
        [-_.~a-zA-Z0-9] ) o="${c}" ;;
        * )               printf -v o '%%%02x' "'$c"
     esac
     encoded+="${o}"
  done
  echo "${encoded}"
}

<!-- All output goes in a "run" subdirectory, which is the place where Brahms sys.xml files and output goes. -->
OUTPUT_DIR="$OUTPUT_DIR_BASE/run"
<!-- Ensure output dir exists -->
mkdir -p "$OUTPUT_DIR"

<!-- Make percent encoded version of OUTPUT_DIR, with %20 for a space etc. Necessary as
     OUTPUT_DIR is passed to xsl's document() function -->
OUTPUT_DIR_PERCENT_ENCODED=$(rawurlencode "$OUTPUT_DIR")

<!-- A temporary code dir. -->
CODE_DIR="$OUTPUT_DIR_BASE/code"
mkdir -p "$CODE_DIR"
<!-- A counter for the code files - so we can save copies of all the component code files. -->
CODE_NUM="0"

<!--
A note about Namespaces

A Brahms installation will exist along with a SpineML_2_BRAHMS installation.
Each installation may have its own namespace, and these are referred to here
as BRAHMS_NS and SPINEML_2_BRAHMS_NS.

All SpineML_2_BRAHMS components are compiled and held in the SPINEML_2_BRAHMS_NS
The BRAHMS_NS contains the Brahms components, as distributed either as the Debian
package or the Brahms binary package. Both namespaces are passed to the brahms call.
-->
SPINEML_2_BRAHMS_NS="$SPINEML_2_BRAHMS_DIR/Namespace"
echo "SPINEML_2_BRAHMS_NS is $SPINEML_2_BRAHMS_NS"
echo "BRAHMS_NS is $BRAHMS_NS"

<!--
 Debugging. Set DEBUG to "true" to add the -g flag to your compile commands so that
 the components will be gdb-debuggable.

 With debuggable components, you can run them using a brahms script
 which calls brahms-execute via valgrind, which is very useful. To do
 that, find your brahms script (`which brahms` will tell you this) and
 make a copy of it, perhaps called brahms-vg. Now modify the way
 brahms-vg calls brahms-execute (prepend valgrind). Now change
 BRAHMS_CMD below so it calls brahms-vg, instead of brahms.
-->
DEBUG="false"

DBG_FLAG=""
if [ $DEBUG = "true" ]; then
# Add -g to compiler flags
DBG_FLAG="-g"
fi

<!-- We have enough information at this point in the script to build our BRAHMS_CMD: -->
BRAHMS_CMD="brahms $VERBOSE_BRAHMS --par-NamespaceRoots=\"$BRAHMS_NS:$SPINEML_2_BRAHMS_NS:$SPINEML_2_BRAHMS_DIR/tools\" \"$OUTPUT_DIR/sys-exe.xml\""

<!--
 If we're in "Sun Grid Engine mode", we can submit our brahms execution scripts
 to the Sun Grid Engine. For each node:
 1. Write out the script (in our OUTPUT_DIR).
 2. qsub it.
-->
if [[ "$NODES" -gt 0 ]]; then # Sun Grid Engine mode

  <!-- Ensure sys-exe.xml is not present to begin with: -->
  rm -f "$OUTPUT_DIR/sys-exe.xml"

  <!-- For each node: -->
  for (( NODE=1; NODE&lt;=$NODES; NODE++ )); do
    echo "Writing run_brahms qsub shell script: $OUTPUT_DIR/run_brahms_$NODE.sh for node $NODE of $NODES"
    cat &gt; "$OUTPUT_DIR/run_brahms_$NODE.sh" &lt;&lt;EOF
#!/bin/sh
#$  -l mem=8G -l h_rt=04:00:00 $NODEARCH
# First, before executing brahms, this script must find out its IP address and write this into a file.

# Obtain first IPv4 address from an eth device.

MYIP=\`ip addr show|grep eth[0-9]|grep inet | awk -F ' ' '{print \$2}' | awk -F '/' '{print \$1}' | head -n1\`
echo "\$MYIP" &gt; "$OUTPUT_DIR/brahms_$NODE.ip"

# Now wait until sys-exe.xml has appeared
while [ ! -f "$OUTPUT_DIR/sys-exe.xml" ]; do
  sleep 1
done

# Finally, can run brahms
cd "$OUTPUT_DIR"
BRAHMS_CMD="brahms $VERBOSE_BRAHMS --par-NamespaceRoots=\"$BRAHMS_NS:$SPINEML_2_BRAHMS_NS:$SPINEML_2_BRAHMS_DIR/tools\" \"$OUTPUT_DIR/sys-exe.xml\" --voice-$NODE"
eval \$BRAHMS_CMD
EOF

  qsub "$OUTPUT_DIR/run_brahms_$NODE.sh"
done
fi

# Set up the include path for rng.h and impulse.h
if [ -f /usr/include/spineml-2-brahms/rng.h ]; then
    # In this case, it looks like the user has the debian package
    SPINEML_2_BRAHMS_INCLUDE_PATH=/usr/include/spineml-2-brahms
else
    # Use a path relative to SPINEML_2_BRAHMS_DIR
    SPINEML_2_BRAHMS_INCLUDE_PATH="$SPINEML_2_BRAHMS_DIR/include"
fi
echo "SPINEML_2_BRAHMS_INCLUDE_PATH=$SPINEML_2_BRAHMS_INCLUDE_PATH"

# Set up the path to the "tools" directory.

# exit on first error
#set -e
if [ "$REBUILD_COMPONENTS" = "true" ]; then
echo "Removing existing components in advance of rebuilding..."
# clean up the temporary dirs - we don't want old component versions lying around!
rm -R "$SPINEML_2_BRAHMS_NS/dev/SpineML/temp"/* &amp;&gt; /dev/null
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
echo "&lt;Number&gt;<xsl:value-of select="$number"/>&lt;/Number&gt;" &amp;&gt; "$OUTPUT_DIR/counter.file"

DIRNAME=&quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0&quot;
CODE_NUM=$((CODE_NUM+1))
diff -q &quot;$MODEL_DIR/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/>&quot; &quot;$DIRNAME/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/>&quot; &amp;&gt; /dev/null
<!-- Check if the component exists and has changed -->
if [ $? == 0 ] &amp;&amp; [ -f &quot;$DIRNAME/component.cpp&quot; ] &amp;&amp; [ -f &quot;$DIRNAME/<xsl:value-of select="$component_output_file"/>&quot; ]; then
echo "Component for population <xsl:value-of select="$number"/> exists, skipping ($DIRNAME/component.cpp)"
<!-- but copy the component into our code folder -->
cp &quot;$DIRNAME/component.cpp&quot; &quot;$CODE_DIR/component$CODE_NUM.cpp&quot;
else
echo "Creating component.cpp for population <xsl:value-of select="$number"/> ($DIRNAME/component.cpp)"
<!-- output_dir passed to concat() and document() functions in SpineML_2_BRAHMS_CL_neurons.xsl so must be % encoded. -->
xsltproc -o "$CODE_DIR/component$CODE_NUM.cpp" --stringparam spineml_output_dir "$OUTPUT_DIR_PERCENT_ENCODED" "$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_neurons.xsl" &quot;$MODEL_DIR/<xsl:value-of select="$model_xml"/>&quot;

if [ ! -f "$CODE_DIR/component$CODE_NUM.cpp" ]; then
echo "Error: no component$CODE_NUM.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_neurons.xsl and the model"
exit -1
fi
mkdir -p &quot;$DIRNAME&quot;
<!-- Copy rng.h and impulse.h -->
cp &quot;$MODEL_DIR/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/>&quot; $SPINEML_2_BRAHMS_INCLUDE_PATH/rng.h $SPINEML_2_BRAHMS_INCLUDE_PATH/impulse.h &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/&quot;
<!-- copy the component.cpp file -->
cp &quot;$CODE_DIR/component$CODE_NUM.cpp&quot; &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/component.cpp&quot;
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;&gt; &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/release.xml&quot;

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;&gt; &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/build&quot;

pushd &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/&quot;
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;&gt; ../../node.xml
chmod +x build
echo "Compiling component binary"
./build
popd &amp;&gt; /dev/null
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
echo "&lt;Nums&gt;&lt;Number1&gt;<xsl:value-of select="$number1"/>&lt;/Number1&gt;&lt;Number2&gt;<xsl:value-of select="$number2"/>&lt;/Number2&gt;&lt;Number3&gt;<xsl:value-of select="$number3"/>&lt;/Number3&gt;&lt;/Nums&gt;" &amp;&gt; "$OUTPUT_DIR/counter.file"

<xsl:variable name="linked_file" select="document(SMLLOWNL:WeightUpdate/@url)"/>
<xsl:variable name="linked_file2" select="document(SMLLOWNL:PostSynapse/@url)"/>
<xsl:variable name="wu_url" select="SMLLOWNL:WeightUpdate/@url"/>
<xsl:variable name="ps_url" select="SMLLOWNL:PostSynapse/@url"/>
DIRNAME=&quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/WU/<xsl:value-of select="local-name(SMLNL:ConnectionList)"/><xsl:value-of select="local-name(SMLNL:FixedProbabilityConnection)"/><xsl:value-of select="local-name(SMLNL:AllToAllConnection)"/><xsl:value-of select="local-name(SMLNL:OneToOneConnection)"/><xsl:value-of select="translate(document(SMLLOWNL:WeightUpdate/@url)//SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0&quot;
CODE_NUM=$((CODE_NUM+1))
diff -q &quot;$MODEL_DIR/<xsl:value-of select="$wu_url"/>&quot; &quot;$DIRNAME/<xsl:value-of select="$wu_url"/>&quot; &amp;&gt; /dev/null
<!--if [ $? == 0 ] &amp;&amp; [ -f "$DIRNAME/component.cpp" ]; then-->
if [ $? == 0 ] &amp;&amp; [ -f &quot;$DIRNAME/component.cpp&quot; ] &amp;&amp; [ -f &quot;$DIRNAME/<xsl:value-of select="$component_output_file"/>&quot; ]; then
<!-- The following echo will create a lot of output, but it's useful for debugging: -->
#echo "Weight Update component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping ($DIRNAME/component.cpp)"
<!-- copy the component into our code folder -->
cp &quot;$DIRNAME/component.cpp&quot; &quot;$CODE_DIR/component$CODE_NUM.cpp&quot;
else
echo "Building weight update component.cpp for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> ($DIRNAME/component.cpp)"
<!-- output_dir passed to concat() and document() functions (as dir_for_numbers) in
     SpineML_2_BRAHMS_CL_weight.xsl so must be % encoded. -->
xsltproc -o "$CODE_DIR/component$CODE_NUM.cpp" --stringparam spineml_model_dir "$MODEL_DIR" --stringparam spineml_output_dir "$OUTPUT_DIR_PERCENT_ENCODED" "$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_weight.xsl" &quot;$MODEL_DIR/<xsl:value-of select="$model_xml"/>&quot;
if [ ! -f "$CODE_DIR/component$CODE_NUM.cpp" ]; then
echo "Error: no component.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_weight.xsl and the model"
exit -1
fi
mkdir -p "$DIRNAME"
cp &quot;$MODEL_DIR/<xsl:value-of select="$wu_url"/>&quot; $SPINEML_2_BRAHMS_INCLUDE_PATH/rng.h $SPINEML_2_BRAHMS_INCLUDE_PATH/impulse.h "$DIRNAME/"
cp "$CODE_DIR/component$CODE_NUM.cpp" "$DIRNAME/component.cpp"
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;&gt; "$DIRNAME/release.xml"

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;&gt; "$DIRNAME/build"

cd "$DIRNAME"

echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;&gt; ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi

DIRNAME=&quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/PS/<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass"><xsl:value-of select="translate(@name,' -', 'oH')"/></xsl:for-each>/brahms/0&quot;
CODE_NUM=$((CODE_NUM+1))
diff -q &quot;$MODEL_DIR/<xsl:value-of select="$ps_url"/>&quot; &quot;$DIRNAME/<xsl:value-of select="$ps_url"/>&quot; &amp;&gt; /dev/null
<!--if [ $? == 0 ] &amp;&amp; [ -f "$DIRNAME/component.cpp" ]; then-->
if [ $? == 0 ] &amp;&amp; [ -f &quot;$DIRNAME/component.cpp&quot; ] &amp;&amp; [ -f &quot;$DIRNAME/<xsl:value-of select="$component_output_file"/>&quot; ]; then
<!-- Lots of output, but useful for debugging: -->
echo "Post-synapse component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping ($DIRNAME/component.cpp)"
<!-- copy the component into our code folder -->
cp &quot;$DIRNAME/component.cpp&quot; &quot;$CODE_DIR/component$CODE_NUM.cpp&quot;
else
echo "Building postsynapse component.cpp for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> ($DIRNAME/component.cpp)"
<!-- output dir passed to document() in SpineML_2_BRAHMS_CL_postsyn.xsl; %-encoding required. -->
xsltproc -o "$CODE_DIR/component$CODE_NUM.cpp" --stringparam spineml_output_dir "$OUTPUT_DIR_PERCENT_ENCODED" "$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_postsyn.xsl" &quot;$MODEL_DIR/<xsl:value-of select="$model_xml"/>&quot;
if [ ! -f "$CODE_DIR/component$CODE_NUM.cpp" ]; then
echo "Error: no component.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_postsyn.xsl and the model"
exit -1
fi
mkdir -p "$DIRNAME"
cp &quot;$MODEL_DIR/<xsl:value-of select="$ps_url"/>&quot; $SPINEML_2_BRAHMS_INCLUDE_PATH/rng.h $SPINEML_2_BRAHMS_INCLUDE_PATH/impulse.h "$DIRNAME/"
cp "$CODE_DIR/component$CODE_NUM.cpp" "$DIRNAME/component.cpp"
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;&gt; "$DIRNAME/release.xml"

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;&gt; "$DIRNAME/build"

cd "$DIRNAME"
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;&gt; ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi
<!-- MORE HERE -->

		</xsl:for-each>
	</xsl:for-each>
</xsl:for-each>

if [ "$REBUILD_SYSTEMML" = "true" ] || [ ! -f "$OUTPUT_DIR/sys.xml" ] ; then
  echo "Building the SystemML system..."
  xsltproc -o "$OUTPUT_DIR/sys.xml" --stringparam spineml_model_dir "$MODEL_DIR" "$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_NL.xsl" "$MODEL_DIR/$INPUT"
else
  echo "Re-using the SystemML system."
fi

if [ "$REBUILD_SYSTEMML" = "true" ] || [ ! -f $OUTPUT_DIR/sys-exe.xml ] ; then

echo "Building the SystemML execution..."

<!--
If in Sun Grid Engine mode and NODES is greater than 1, need to read all IP addresses
before building sys-exe.xml. Write the voices into a small xml file - brahms_voices.xml
- which will be used as input to xsltproc.
-->
if [[ "$NODES" -gt 1 ]]; then
  for (( NODE=1; NODE&lt;=$NODES; NODE++ )); do
    COUNTER="1"
    <!-- Note that we have a 120 second timeout for getting the node IP here - this
         is effectively the time that you have to wait for the SGE to start the job. -->
    SUN_GRID_ENGINE_TIMEOUT="120"
    echo "Waiting up to $SUN_GRID_ENGINE_TIMEOUT seconds for node $NODE to record its IP address..."
    while [ ! -f "$OUTPUT_DIR/brahms_$NODE.ip" ] &amp;&amp; [ "$COUNTER" -lt "$SUN_GRID_ENGINE_TIMEOUT" ]; do
      sleep 1
      COUNTER=$((COUNTER+1))
    done
    if [ ! -f "$OUTPUT_DIR/brahms_$NODE.ip" ]; then
      <!-- Still no IP, that's an error. -->
      echo "Error: Failed to learn IP address for brahms node $NODE, exiting."
      exit -1
    fi <!-- else we have the IP, so can read it to send it into the xsltproc call. -->
  done

  echo -n "&lt;Voices&gt;" &gt; "$OUTPUT_DIR/brahms_voices.xml"
  for (( NODE=1; NODE&lt;=$NODES; NODE++ )); do
    read NODEIP &lt; "$OUTPUT_DIR/brahms_$NODE.ip"
    echo -n "&lt;Voice&gt;&lt;Address protocol=\&quot;sockets\&quot;&gt;$NODEIP&lt;/Address&gt;&lt;/Voice&gt;" &gt;&gt; "$OUTPUT_DIR/brahms_voices.xml"
  done
  echo -n "&lt;/Voices&gt;" &gt;&gt; "$OUTPUT_DIR/brahms_voices.xml"
else
  echo "&lt;Voices&gt;&lt;Voice/&gt;&lt;/Voices&gt;" &gt; "$OUTPUT_DIR/brahms_voices.xml"
fi

<!-- OUTPUT_DIR/voices_file passed to document() function in SpineML_2_BRAHMS_EXPT.xsl; must be %-encoded. -->
xsltproc -o "$OUTPUT_DIR/sys-exe.xml" --stringparam voices_file "$OUTPUT_DIR_PERCENT_ENCODED/brahms_voices.xml" "$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_EXPT.xsl" "$MODEL_DIR/$INPUT"

else
  echo "Re-using the SystemML execution."
fi

echo "Done!"

<!-- If not in Sun Grid Engine mode, run! -->
if [[ "$NODES" -eq 0 ]]; then
  cd "$OUTPUT_DIR"
  echo -n "Executing: $BRAHMS_CMD from pwd: "
  echo `pwd`
  eval $BRAHMS_CMD
else
  echo "Simulation has been submitted to Sun Grid Engine."
fi
</xsl:when>
<!-- END SMLLOWNL SECTION -->
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


