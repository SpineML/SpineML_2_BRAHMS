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
    <xsl:if test="$hostos='OSX'">-undefined dynamic_lookup -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -fPIC -O3 -dynamiclib</xsl:if>
</xsl:variable>

<!-- this could go - there's no longer a need to link against
     libbrahms-engine on any platform -->
<xsl:variable name="linker_flags">
    <!-- <xsl:if test="$hostos='OSX'">-L`brahms \-\-showlib`</xsl:if> -->
</xsl:variable>

<xsl:variable name="component_output_file">
    <xsl:if test="$hostos='Linux32' or $hostos='Linux64'">component.so</xsl:if>
    <xsl:if test="$hostos='OSX'">component.dylib</xsl:if>
</xsl:variable>

<xsl:variable name="platform_specific_includes">
    <xsl:if test="$hostos='Linux32' or $hostos='Linux64'">-I`brahms --showinclude` -I`brahms --shownamespace`</xsl:if>
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
OUTPUT_DIR_BASE=$7 <!-- The base directory of the output directory tree. -->
XSL_SCRIPT_PATH=$8
VERBOSE_BRAHMS=${9}

<!--
    Here's a variable that can be set to avoid the component testing
    from going ahead. This may be useful when you are running your sim
    many times and you don't want the component check to happen each
    time; it may take a few seconds for large models. If you prefer
    NOT to assume components are present, then set this blank.
    -->
ASSUME_COMPONENTS_PRESENT=${10}
<!-- If set to "yes" then build with -g, create ~/gdbcmd, and call brahms-gdb -->
BRAHMS_DEBUG=${11}

BRAHMS_NOGUI=${12}
NODES=${13} <!-- Number of machine nodes to use. If >1, then this assumes we're using Sun Grid Engine. -->
NODEARCH=${14}

echo &quot;VERBOSE_BRAHMS: $VERBOSE_BRAHMS&quot;
echo &quot;BRAHMS_DEBUG: $BRAHMS_DEBUG&quot;

<!-- Test brahms version -->
BRAHMS_VERSION=`brahms --ver`
VERSION_BRAHMS_MAJ=`echo $BRAHMS_VERSION | awk -F'.' '{print $1}'`
VERSION_BRAHMS_MIN=`echo $BRAHMS_VERSION | awk -F'.' '{print $2}'`
VERSION_BRAHMS_REL=`echo $BRAHMS_VERSION | awk -F'.' '{print $3}'`
VERSION_BRAHMS_REV=`echo $BRAHMS_VERSION | awk -F'.' '{print $4}'`
VERSION_TOO_OLD=0
if [ $VERSION_BRAHMS_MAJ -ge 0 ]; then
  echo &quot;VERSION_BRAHMS_MAJ=$VERSION_BRAHMS_MAJ: ok&quot;
  if [ $VERSION_BRAHMS_MIN -ge 8 ]; then
    echo &quot;VERSION_BRAHMS_MIN=$VERSION_BRAHMS_MIN: ok&quot;
    if [ $VERSION_BRAHMS_REL -ge 0 ]; then
      echo &quot;VERSION_BRAHMS_REL=$VERSION_BRAHMS_REL: ok&quot;
      if [ $VERSION_BRAHMS_REV -ge 1 ]; then
        echo &quot;VERSION_BRAHMS_REV=$VERSION_BRAHMS_REV: ok&quot;
      else # 1
        VERSION_TOO_OLD=1
      fi
    else # 2
      VERSION_TOO_OLD=1
    fi
  else # 3
    VERSION_TOO_OLD=1
  fi
else # 4
  VERSION_TOO_OLD=1
fi

if [ x&quot;$VERSION_TOO_OLD&quot; = &quot;x&quot;1 ]; then
  echo &quot;This version of SpineML_2_BRAHMS requires BRAHMS version 0.8.0.1 or greater. Exiting.&quot;
  exit 1
fi
<!-- Completed test of brahms version -->

echo &quot;NODES: $NODES&quot;
echo &quot;NODEARCH: $NODEARCH&quot;

if [ &quot;x$VERBOSE_BRAHMS&quot; = &quot;xno&quot; ]; then
  VERBOSE_BRAHMS=&quot;&quot;
fi

if [ &quot;x$NODES&quot; = &quot;x&quot; ]; then
  NODES=0
fi

<!-- Is user requesting specific architecture? -->
if [ &quot;x$NODEARCH&quot; = &quot;xamd&quot; ]; then
  NODEARCH=&quot;-l arch=amd*&quot;
elif [ &quot;x$NODEARCH&quot; = &quot;xintel&quot; ]; then
  NODEARCH=&quot;-l arch=intel*&quot;
else
  echo &quot;Ignoring invalid node architecture '$NODEARCH'&quot;
  NODEARCH=&quot;&quot;
fi

<!-- Are we in Sun Grid Engine mode? -->
if [[ &quot;$NODES&quot; -gt 0 ]]; then
  echo &quot;Submitting execution Sun Grid Engine with $NODES nodes.&quot;
fi

<!-- Working directory - need to pass this to xsl scripts as we no
     longer have them inside the current working tree. -->
echo &quot;SPINEML_2_BRAHMS_DIR is $SPINEML_2_BRAHMS_DIR&quot;

<!-- Some paths need to be URL encoded. -->
rawurlencode() {
  local string=&quot;${1}&quot;
  local strlen=${#string}
  local encoded=&quot;&quot;

  for (( pos=0 ; pos&lt;strlen ; pos++ )); do
     c=${string:$pos:1}
     case &quot;$c&quot; in
        [-_.~a-zA-Z0-9] ) o=&quot;${c}&quot; ;;
        * )               printf -v o '%%%02x' &quot;'$c&quot;
     esac
     encoded+=&quot;${o}&quot;
  done
  echo &quot;${encoded}&quot;
}

<!-- All brahms files go in a &quot;run&quot; subdirectory - sys.xml, sys-exe.xml, and so on.. -->
<!-- Update - this is SPINEML_RUN_DIR -->
SPINEML_RUN_DIR=&quot;$OUTPUT_DIR_BASE/run&quot;
<!-- Ensure output dir exists -->
mkdir -p &quot;$SPINEML_RUN_DIR&quot;

<!-- Make percent encoded version of SPINEML_RUN_DIR, with %20 for a space etc. Necessary as
     SPINEML_RUN_DIR is passed to xsl's document() function -->
SPINEML_RUN_DIR_PERCENT_ENCODED=$(rawurlencode "$SPINEML_RUN_DIR")

<!-- The dir for component logs. Because log is always ../log wrt
     SPINEML_RUN_DIR, we don't actually pass this to any XSL. -->
SPINEML_LOG_DIR="$OUTPUT_DIR_BASE/log"
SPINEML_LOG_DIR_PERCENT_ENCODED=$(rawurlencode "$SPINEML_LOG_DIR")
mkdir -p "$SPINEML_LOG_DIR"

<!-- A code dir in which the generated cpp files are left around for
     the user to inspect/debug -->
SPINEML_CODE_DIR=&quot;$SPINEML_RUN_DIR/code&quot;
mkdir -p &quot;$SPINEML_CODE_DIR&quot;
<!-- A counter for the code files - so we can save copies of all the component code files. -->
CODE_NUM=&quot;0&quot;

<!-- The model dir is passed to xsl scripts, but it's used in such a way
     that we DON'T want a percent encoded version -->

<!--
A note about Namespaces

A Brahms installation will exist along with a SpineML_2_BRAHMS installation.
Each installation may have its own namespace, and these are referred to here
as BRAHMS_NS and SPINEML_2_BRAHMS_NS.

All SpineML_2_BRAHMS components are compiled and held in the SPINEML_2_BRAHMS_NS
The BRAHMS_NS contains the Brahms components, as distributed either as the Debian
package or the Brahms binary package. Both namespaces are passed to the brahms call.
-->
SPINEML_2_BRAHMS_NS=&quot;$SPINEML_2_BRAHMS_DIR/Namespace&quot;
echo &quot;SPINEML_2_BRAHMS_NS is $SPINEML_2_BRAHMS_NS&quot;
echo &quot;BRAHMS_NS is $BRAHMS_NS&quot;

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
DBG_FLAG=&quot;&quot;
BRAHMS_EXE=&quot;brahms&quot;
if [ &quot;x${BRAHMS_DEBUG}&quot; = &quot;xyes&quot; ]; then

    # Add -g to compiler flags
    DBG_FLAG=&quot;-g&quot;

    # Use the brahms-gdb script as the brahm exe
    BRAHMS_EXE=&quot;brahms-gdb&quot;

    # If rebuild-all then move gdbcmd, so it will be re-generated and
    # all the newly re-built components will have a corresponding entry
    # in gdbcmd.
    if [ -f ~/gdbcmd ] &amp;&amp; [ &quot;$REBUILD_COMPONENTS&quot; = &quot;true&quot; ]; then
        mv -f ~/gdbcmd ~/gdbcmd.save
    fi

    # Initialise gdbcmd if it doesn't exist.
    if [ ! -f ~/gdbcmd ]; then
        echo &quot;dir ~/src/brahms&quot; > ~/gdbcmd
    fi
fi

<!-- We have enough information at this point in the script to build our BRAHMS_CMD: -->
BRAHMS_CMD=&quot;${BRAHMS_EXE} $VERBOSE_BRAHMS $BRAHMS_NOGUI --par-NamespaceRoots=\&quot;$BRAHMS_NS:$SPINEML_2_BRAHMS_NS:$SPINEML_2_BRAHMS_DIR/tools\&quot; \&quot;$SPINEML_RUN_DIR/sys-exe.xml\&quot;&quot;


<!--
 If we're in "Sun Grid Engine mode", we can submit our brahms execution scripts
 to the Sun Grid Engine. For each node:
 1. Write out the script (in our SPINEML_RUN_DIR).
 2. qsub it.
-->
if [[ &quot;$NODES&quot; -gt 0 ]]; then # Sun Grid Engine mode

  <!-- Ensure sys-exe.xml is not present to begin with: -->
  rm -f &quot;$SPINEML_RUN_DIR/sys-exe.xml&quot;

  <!-- For each node: -->
  for (( NODE=1; NODE&lt;=$NODES; NODE++ )); do
    echo &quot;Writing run_brahms qsub shell script: $SPINEML_RUN_DIR/run_brahms_$NODE.sh for node $NODE of $NODES&quot;
    cat &gt; &quot;$SPINEML_RUN_DIR/run_brahms_$NODE.sh&quot; &lt;&lt;EOF
#!/bin/sh
#$  -l mem=8G -l h_rt=04:00:00 $NODEARCH
# First, before executing brahms, this script must find out its IP address and write this into a file.

# Obtain first IPv4 address from an eth device.

MYIP=\`ip addr show|grep eth[0-9]|grep inet | awk -F ' ' '{print \$2}' | awk -F '/' '{print \$1}' | head -n1\`
echo &quot;\$MYIP&quot; &gt; &quot;$SPINEML_RUN_DIR/brahms_$NODE.ip&quot;

# Now wait until sys-exe.xml has appeared
while [ ! -f &quot;$SPINEML_RUN_DIR/sys-exe.xml&quot; ]; do
  sleep 1
done

# Finally, can run brahms
cd &quot;$SPINEML_RUN_DIR&quot;
BRAHMS_CMD=&quot;brahms $VERBOSE_BRAHMS --par-NamespaceRoots=\&quot;$BRAHMS_NS:$SPINEML_2_BRAHMS_NS:$SPINEML_2_BRAHMS_DIR/tools\&quot; \&quot;$SPINEML_RUN_DIR/sys-exe.xml\&quot; --voice-$NODE&quot;
eval \$BRAHMS_CMD
EOF

  qsub &quot;$SPINEML_RUN_DIR/run_brahms_$NODE.sh&quot;
done
fi

# Set up the include path for rng.h and impulse.h
if [ -f /usr/include/spineml-2-brahms/rng.h ]; then
    # In this case, it looks like the user has the debian package
    echo &quot;I THINK USER HAS DEBIAN PACKAGE&quot;
    SPINEML_2_BRAHMS_INCLUDE_PATH=/usr/include/spineml-2-brahms
else
    # Use a path relative to SPINEML_2_BRAHMS_DIR
    SPINEML_2_BRAHMS_INCLUDE_PATH=&quot;$SPINEML_2_BRAHMS_DIR/include&quot;
fi
echo &quot;SPINEML_2_BRAHMS_INCLUDE_PATH=$SPINEML_2_BRAHMS_INCLUDE_PATH&quot;

# Set up the path to the &quot;tools&quot; directory.

# exit on first error
#set -e
if [ &quot;$REBUILD_COMPONENTS&quot; = &quot;true&quot; ]; then
echo &quot;Removing existing components in advance of rebuilding...&quot;
# clean up the temporary dirs - we don't want old component versions lying around!
rm -R &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp&quot;/* &amp;&gt; /dev/null
fi

if [ ! x&quot;${ASSUME_COMPONENTS_PRESENT}&quot; = &quot;x&quot; ]; then
echo &quot;DANGER:&quot;
echo &quot;DANGER: output.script is ASSUMING that all SpineML components have been built!&quot;
echo &quot;DANGER: (you would want to do this if running the model over and over with a batch script)&quot;
echo &quot;DANGER:&quot;
fi

if [ x&quot;${ASSUME_COMPONENTS_PRESENT}&quot; = &quot;x&quot; ]; then

echo &quot;Creating the Neuron populations...&quot;

<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
# Also update time.txt for SpineCreator / other tools
echo &quot;*Compiling neuron <xsl:value-of select="position()"/> / <xsl:value-of select="count(/SMLLOWNL:SpineML/SMLLOWNL:Population)"/>&quot; &gt; &quot;${MODEL_DIR}/time.txt&quot;
<xsl:choose>
<xsl:when test="./SMLLOWNL:Neuron/@url = 'SpikeSource'">
echo &quot;SpikeSource, skipping compile&quot;
</xsl:when>
<xsl:otherwise>
<xsl:variable name="linked_file" select="document(./SMLLOWNL:Neuron/@url)"/>
<!-- Here we use the population number to determine which Neuron type we are outputting -->
<xsl:variable name="number"><xsl:number count="/SMLLOWNL:SpineML/SMLLOWNL:Population" format="1"/></xsl:variable>
echo &quot;&lt;Number&gt;<xsl:value-of select="$number"/>&lt;/Number&gt;&quot; &amp;&gt; &quot;$SPINEML_RUN_DIR/counter.file&quot;

DIRNAME=&quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0&quot;
CODE_NUM=$((CODE_NUM+1))
diff -q &quot;$MODEL_DIR/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/>&quot; &quot;$DIRNAME/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/>&quot; &amp;&gt; /dev/null
<!-- Check if the component exists and has changed -->
if [ $? == 0 ] &amp;&amp; [ -f &quot;$DIRNAME/component.cpp&quot; ] &amp;&amp; [ -f &quot;$DIRNAME/<xsl:value-of select="$component_output_file"/>&quot; ]; then
echo &quot;Component for population <xsl:value-of select="$number"/> exists, skipping ($DIRNAME/component.cpp)&quot;
<!-- but copy the component into our code folder -->
cp &quot;$DIRNAME/component.cpp&quot; &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot;
else
echo &quot;Creating component.cpp for population <xsl:value-of select="$number"/> ($DIRNAME/component.cpp)&quot;
<!-- output_dir passed to concat() and document() functions in SpineML_2_BRAHMS_CL_neurons.xsl so must be % encoded. -->
xsltproc -o &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; --stringparam spineml_run_dir &quot;$SPINEML_RUN_DIR_PERCENT_ENCODED&quot; &quot;$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_neurons.xsl&quot; &quot;$MODEL_DIR/<xsl:value-of select="$model_xml"/>&quot;
XSLTPROCRTN=$?
echo &quot;xsltproc (for population component creation) returned: $XSLTPROCRTN&quot;
if [ $XSLTPROCRTN -ne &quot;0&quot; ]; then
  echo &quot;XSLT error generating population/neuron body component; exiting&quot;
  exit $XSLTPROCRTN
fi
if [ ! -f &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; ]; then
echo &quot;Error: no component$CODE_NUM.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_neurons.xsl and the model&quot;
exit -1
fi
mkdir -p &quot;$DIRNAME&quot;
<!-- Copy rng.h and impulse.h -->
cp &quot;$MODEL_DIR/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/>&quot; &quot;${SPINEML_2_BRAHMS_INCLUDE_PATH}/rng.h&quot; &quot;${SPINEML_2_BRAHMS_INCLUDE_PATH}/impulse.h&quot; &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/&quot;
<!-- copy the component.cpp file -->
cp &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/component.cpp&quot;
echo &quot;&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;&quot; &amp;&gt; &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/release.xml&quot;

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I`brahms --showinclude` -I`brahms --shownamespace` <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;&gt; &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/build&quot;

pushd &quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/&quot;
if [ &quot;x${BRAHMS_DEBUG}&quot; = &quot;xyes&quot; ]; then
    # search for gdbcmd line and and add if necessary.
    grep -q -F &quot;dir `pwd`&quot; ~/gdbcmd || echo &quot;dir `pwd`&quot; &gt;&gt; ~/gdbcmd
fi
echo &quot;&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;&quot; &amp;&gt; ../../node.xml
chmod +x build
echo &quot;Compiling component binary&quot;
./build
popd &amp;&gt; /dev/null
fi # The check if component code exists

</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
fi # The enclosing check if the user wants to skip component existence checking



if [ x&quot;${ASSUME_COMPONENTS_PRESENT}&quot; = &quot;x&quot; ]; then
echo &quot;Creating the projections...&quot;
<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
# Also update time.txt for SpineCreator / other tools
echo &quot;*Compiling projections <xsl:value-of select="position()"/> / <xsl:value-of select="count(/SMLLOWNL:SpineML/SMLLOWNL:Population//SMLLOWNL:Projection)"/>&quot; &gt; &quot;${MODEL_DIR}/time.txt&quot;

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
echo &quot;&lt;Nums&gt;&lt;Number1&gt;<xsl:value-of select="$number1"/>&lt;/Number1&gt;&lt;Number2&gt;<xsl:value-of select="$number2"/>&lt;/Number2&gt;&lt;Number3&gt;<xsl:value-of select="$number3"/>&lt;/Number3&gt;&lt;/Nums&gt;&quot; &amp;&gt; &quot;$SPINEML_RUN_DIR/counter.file&quot;

<xsl:variable name="linked_file" select="document(SMLLOWNL:WeightUpdate/@url)"/>
<xsl:variable name="linked_file2" select="document(SMLLOWNL:PostSynapse/@url)"/>
<xsl:variable name="wu_url" select="SMLLOWNL:WeightUpdate/@url"/>
<xsl:variable name="ps_url" select="SMLLOWNL:PostSynapse/@url"/>

DIRNAME=&quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/WU/<xsl:value-of select="local-name(SMLNL:ConnectionList)"/><xsl:value-of select="local-name(SMLNL:FixedProbabilityConnection)"/><xsl:value-of select="local-name(SMLNL:AllToAllConnection)"/><xsl:value-of select="local-name(SMLNL:OneToOneConnection)"/><xsl:value-of select="translate(document(SMLLOWNL:WeightUpdate/@url)//SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0&quot;
CODE_NUM=$((CODE_NUM+1))
diff -q &quot;$MODEL_DIR/<xsl:value-of select="$wu_url"/>&quot; &quot;$DIRNAME/<xsl:value-of select="$wu_url"/>&quot; &amp;&gt; /dev/null
<!-- Check that the postsynapse component exists -->
if [ $? == 0 ] &amp;&amp; [ -f &quot;$DIRNAME/component.cpp&quot; ] &amp;&amp; [ -f &quot;$DIRNAME/<xsl:value-of select="$component_output_file"/>&quot; ]; then
<!-- The following echo will create a lot of output, but it's useful for debugging: -->
#echo &quot;Weight Update component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping ($DIRNAME/component.cpp)&quot;
<!-- copy the component into our code folder -->
cp &quot;$DIRNAME/component.cpp&quot; &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot;
else
echo &quot;Building weight update component.cpp for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> ($DIRNAME/component.cpp)&quot;
<!-- output_dir passed to concat() and document() functions (as dir_for_numbers) in
     SpineML_2_BRAHMS_CL_weight.xsl so must be % encoded. -->
xsltproc -o &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; --stringparam spineml_model_dir &quot;${MODEL_DIR}&quot; --stringparam spineml_run_dir &quot;$SPINEML_RUN_DIR_PERCENT_ENCODED&quot; &quot;$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_weight.xsl&quot; &quot;$MODEL_DIR/<xsl:value-of select="$model_xml"/>&quot;
XSLTPROCRTN=$?
echo &quot;xsltproc (for weight update component creation) returned: $XSLTPROCRTN&quot;
if [ $XSLTPROCRTN -ne &quot;0&quot; ]; then
  echo &quot;XSLT error generating weight update component; exiting&quot;
  exit $XSLTPROCRTN
fi
if [ ! -f &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; ]; then
echo &quot;Error: no component.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_weight.xsl and the model&quot;
exit -1
fi
mkdir -p &quot;$DIRNAME&quot;
cp &quot;$MODEL_DIR/<xsl:value-of select="$wu_url"/>&quot; &quot;${SPINEML_2_BRAHMS_INCLUDE_PATH}/rng.h&quot; &quot;${SPINEML_2_BRAHMS_INCLUDE_PATH}/impulse.h&quot; &quot;${DIRNAME}/&quot;
cp &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; &quot;${DIRNAME}/component.cpp&quot;
echo &quot;&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;&quot; &amp;&gt; &quot;$DIRNAME/release.xml&quot;

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I`brahms --showinclude` -I`brahms --shownamespace` <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;&gt; &quot;$DIRNAME/build&quot;

cd &quot;$DIRNAME&quot;
<!-- Add to the debugging gdbcmd file: -->
if [ &quot;x${BRAHMS_DEBUG}&quot; = &quot;xyes&quot; ]; then
    grep -q -F &quot;dir `pwd`&quot; ~/gdbcmd || echo &quot;dir `pwd`&quot; &gt;&gt; ~/gdbcmd
fi

echo &quot;&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;&quot; &amp;&gt; ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi <!-- end check that the weight update component code exists -->

DIRNAME=&quot;$SPINEML_2_BRAHMS_NS/dev/SpineML/temp/PS/<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass"><xsl:value-of select="translate(@name,' -', 'oH')"/></xsl:for-each>/brahms/0&quot;
CODE_NUM=$((CODE_NUM+1))
diff -q &quot;$MODEL_DIR/<xsl:value-of select="$ps_url"/>&quot; &quot;$DIRNAME/<xsl:value-of select="$ps_url"/>&quot; &amp;&gt; /dev/null
<!-- Check that the postsynapse component exists -->
if [ $? == 0 ] &amp;&amp; [ -f &quot;$DIRNAME/component.cpp&quot; ] &amp;&amp; [ -f &quot;$DIRNAME/<xsl:value-of select="$component_output_file"/>&quot; ]; then
<!-- Lots of output, but useful for debugging: -->
echo &quot;Post-synapse component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping ($DIRNAME/component.cpp)&quot;
<!-- copy the component into our code folder -->
cp &quot;$DIRNAME/component.cpp&quot; &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot;
else
echo &quot;Building postsynapse component.cpp for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> ($DIRNAME/component.cpp)&quot;
<!-- output dir passed to document() in SpineML_2_BRAHMS_CL_postsyn.xsl; %-encoding required. -->
xsltproc -o &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; --stringparam spineml_run_dir &quot;$SPINEML_RUN_DIR_PERCENT_ENCODED&quot; &quot;$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_CL_postsyn.xsl&quot; &quot;$MODEL_DIR/<xsl:value-of select="$model_xml"/>&quot;
XSLTPROCRTN=$?
echo &quot;xsltproc (for postsynapse component creation) returned: $XSLTPROCRTN&quot;
if [ $XSLTPROCRTN -ne &quot;0&quot; ]; then
  echo &quot;XSLT error generating postsynapse component; exiting&quot;
  exit $XSLTPROCRTN
fi
if [ ! -f &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; ]; then
echo &quot;Error: no component.cpp was generated by xsltproc from LL/SpineML_2_BRAHMS_CL_postsyn.xsl and the model&quot;
exit -1
fi
mkdir -p &quot;$DIRNAME&quot;
cp &quot;$MODEL_DIR/<xsl:value-of select="$ps_url"/>&quot; &quot;${SPINEML_2_BRAHMS_INCLUDE_PATH}/rng.h&quot; &quot;${SPINEML_2_BRAHMS_INCLUDE_PATH}/impulse.h&quot; &quot;$DIRNAME/&quot;
cp &quot;$SPINEML_CODE_DIR/component$CODE_NUM.cpp&quot; &quot;$DIRNAME/component.cpp&quot;
echo &quot;&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;&quot; &amp;&gt; &quot;$DIRNAME/release.xml&quot;

echo 'g++ '$DBG_FLAG' <xsl:value-of select="$compiler_flags"/> component.cpp -o <xsl:value-of select="$component_output_file"/> -I`brahms --showinclude` -I`brahms --shownamespace` <xsl:value-of select="$platform_specific_includes"/> <xsl:value-of select="$linker_flags"/>' &amp;&gt; &quot;$DIRNAME/build&quot;

cd &quot;$DIRNAME&quot;
if [ &quot;x${BRAHMS_DEBUG}&quot; = &quot;xyes&quot; ]; then
    grep -q -F &quot;dir `pwd`&quot; ~/gdbcmd || echo &quot;dir `pwd`&quot; &gt;&gt; ~/gdbcmd
fi

echo &quot;&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;&quot; &amp;&gt; ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi <!-- end check that the postsynapse component exists -->
<!-- MORE HERE -->
</xsl:for-each>
</xsl:for-each>
</xsl:for-each>

fi <!-- end "assume" test -->

if [ &quot;$REBUILD_SYSTEMML&quot; = &quot;true&quot; ] || [ ! -f &quot;$SPINEML_RUN_DIR/sys.xml&quot; ] ; then
  echo &quot;Building the SystemML system...&quot;

  # Before calling xsltproc, check if the SpineML system has its own
  # external.xsl file for xsl/LL. If not, then copy
  # $XSL_SCRIPT_PATH/LL/external_default.xsl to
  # $XSL_SCRIPT_PATH/LL/external.xsl
  if [ -f &quot;${MODEL_DIR}/external.xsl&quot; ]; then
    cp &quot;${MODEL_DIR}/external.xsl&quot; &quot;${XSL_SCRIPT_PATH}/LL/external.xsl&quot;
  else
    cp &quot;${XSL_SCRIPT_PATH}/LL/external_default.xsl&quot; &quot;${XSL_SCRIPT_PATH}/LL/external.xsl&quot;
  fi

  # Below line only works with very latest versions of xsltproc
  #xsltproc --maxdepth 50000 --maxvars 500000 -o &quot;$SPINEML_RUN_DIR/sys.xml&quot; --stringparam spineml_model_dir &quot;$MODEL_DIR&quot; &quot;$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_NL.xsl&quot; &quot;$MODEL_DIR/$INPUT&quot;
  xsltproc -o &quot;$SPINEML_RUN_DIR/sys.xml&quot; --stringparam spineml_model_dir &quot;$MODEL_DIR&quot; &quot;$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_NL.xsl&quot; &quot;$MODEL_DIR/$INPUT&quot;
  XSLTPROCRTN=$?
  echo &quot;xsltproc (for SystemML system) returned: $XSLTPROCRTN&quot;
  if [ $XSLTPROCRTN -ne &quot;0&quot; ]; then
    echo &quot;XSLT error generating SystemML system; exiting&quot;
    exit $XSLTPROCRTN
  fi
else
  echo &quot;Re-using the SystemML system.&quot;
fi

if [ &quot;$REBUILD_SYSTEMML&quot; = &quot;true&quot; ] || [ ! -f $SPINEML_RUN_DIR/sys-exe.xml ] ; then

echo &quot;Building the SystemML execution...&quot;

<!--
If in Sun Grid Engine mode and NODES is greater than 1, need to read all IP addresses
before building sys-exe.xml. Write the voices into a small xml file - brahms_voices.xml
- which will be used as input to xsltproc.
-->
if [[ &quot;$NODES&quot; -gt 1 ]]; then
  for (( NODE=1; NODE&lt;=$NODES; NODE++ )); do
    COUNTER=&quot;1&quot;
    <!-- Note that we have a 120 second timeout for getting the node IP here - this
         is effectively the time that you have to wait for the SGE to start the job. -->
    SUN_GRID_ENGINE_TIMEOUT=&quot;120&quot;
    echo &quot;Waiting up to $SUN_GRID_ENGINE_TIMEOUT seconds for node $NODE to record its IP address...&quot;
    while [ ! -f &quot;$SPINEML_RUN_DIR/brahms_$NODE.ip&quot; ] &amp;&amp; [ &quot;$COUNTER&quot; -lt &quot;$SUN_GRID_ENGINE_TIMEOUT&quot; ]; do
      sleep 1
      COUNTER=$((COUNTER+1))
    done
    if [ ! -f &quot;$SPINEML_RUN_DIR/brahms_$NODE.ip&quot; ]; then
      <!-- Still no IP, that's an error. -->
      echo &quot;Error: Failed to learn IP address for brahms node $NODE, exiting.&quot;
      exit -1
    fi <!-- else we have the IP, so can read it to send it into the xsltproc call. -->
  done

  echo -n &quot;&lt;Voices&gt;&quot; &gt; &quot;$SPINEML_RUN_DIR/brahms_voices.xml&quot;
  for (( NODE=1; NODE&lt;=$NODES; NODE++ )); do
    read NODEIP &lt; &quot;$SPINEML_RUN_DIR/brahms_$NODE.ip&quot;
    echo -n &quot;&lt;Voice&gt;&lt;Address protocol=\&quot;sockets\&quot;&gt;$NODEIP&lt;/Address&gt;&lt;/Voice&gt;&quot; &gt;&gt; &quot;$SPINEML_RUN_DIR/brahms_voices.xml&quot;
  done
  echo -n &quot;&lt;/Voices&gt;&quot; &gt;&gt; &quot;$SPINEML_RUN_DIR/brahms_voices.xml&quot;
else
  echo &quot;&lt;Voices&gt;&lt;Voice/&gt;&lt;/Voices&gt;&quot; &gt; &quot;$SPINEML_RUN_DIR/brahms_voices.xml&quot;
fi

<!-- SPINEML_RUN_DIR/voices_file passed to document() function in SpineML_2_BRAHMS_EXPT.xsl; must be %-encoded. -->
xsltproc -o &quot;$SPINEML_RUN_DIR/sys-exe.xml&quot; --stringparam voices_file &quot;$SPINEML_RUN_DIR_PERCENT_ENCODED/brahms_voices.xml&quot; &quot;$XSL_SCRIPT_PATH/LL/SpineML_2_BRAHMS_EXPT.xsl&quot; &quot;$MODEL_DIR/$INPUT&quot;
XSLTPROCRTN=$?
echo &quot;xsltproc (for sys-exe.xml) returned: $XSLTPROCRTN&quot;
if [ $XSLTPROCRTN -ne &quot;0&quot; ]; then
  echo &quot;XSLT error generating sys-exe.xml; exiting&quot;
  exit $XSLTPROCRTN
fi

else
  echo &quot;Re-using the SystemML execution.&quot;
fi

echo &quot;Done!&quot;

<!-- Finish up gdbcmd -->
if [ &quot;x${BRAHMS_DEBUG}&quot; = &quot;xyes&quot; ]; then
    echo &quot;run&quot; >> ~/gdbcmd
fi


<!-- If not in Sun Grid Engine mode, run! -->
if [[ &quot;$NODES&quot; -eq 0 ]]; then
  cd &quot;$SPINEML_RUN_DIR&quot;
  echo -n &quot;Executing: $BRAHMS_CMD from pwd: &quot;
  echo `pwd`
  eval $BRAHMS_CMD
else
  echo &quot;Simulation has been submitted to Sun Grid Engine.&quot;
fi
</xsl:when>
<!-- END SMLLOWNL SECTION -->
<!-- SpineML high level network layer -->
<!-- FIXME: Need to reproduce the script above for SMLLOWNL here, with SMLLOWNL replaced by SMLNL: -->
<xsl:when test="SMLNL:SpineML">#/bin/bash
echo &quot;Duplicate code for the SMLLOWNL case from START SMLLOWNL SECTION to END SMLLOWNL SECTION.&quot;
exit 1
</xsl:when>
<xsl:otherwise>
echo &quot;ERROR: Unrecognised SpineML Network Layer file&quot;
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>
