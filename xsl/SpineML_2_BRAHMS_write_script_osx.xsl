<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:NMLEX="http://www.shef.ac.uk/SpineMLExperimentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
<xsl:template match="/">
<!-- OK, THIS IS THE PLATFORM SPECIFIC XSLT SCRIPT THAT GENERATES THE SIMPLE SCRIPT TO CREATE THE PROCESSES / SYSTEM -->
<!-- VERSION = OSX -->

<!-- since we start in the experiment file we need to use for-each to get to the model file -->
<xsl:variable name="model_xml" select="//NMLEX:Model/@network_layer_url"/>
<xsl:for-each select="document(//NMLEX:Model/@network_layer_url)">

<xsl:choose>

<xsl:when test="SMLLOWNL:SpineML">

#!/bin/bash
INPUT=$1
REBUILD=$2
BRAHMS_NS=$3

DEBUG="false"

if [ $DEBUG = "true" ]; then
REBUILD="true"
fi

# exit on first error
#set -e
if [ $REBUILD = "true" ]; then
# clean up the temporary dirs - we don't want old component versions lying around!
rm -R $BRAHMS_NS/dev/SpineML/temp/*  &amp;> /dev/null
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
DIRNAME=$BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
#if [ -d "$DIRNAME" ]; then
diff -q ../model/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/> $DIRNAME/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/> &amp;> /dev/null
if [ $?  == 0 ]; then
echo "Component for population <xsl:value-of select="$number"/> exists, skipping"
else
xsltproc -o component.cpp ../xsl/LL/SpineML_2_BRAHMS_CL_neurons.xsl ../model/<xsl:value-of select="$model_xml"/>
echo "Building component for population <xsl:value-of select="$number"/>"
mkdir -p $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
cp ../model/<xsl:value-of select="./SMLLOWNL:Neuron/@url"/> ./component.cpp ../include/rng.h ../include/impulse.h $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/release.xml

if [ $DEBUG = "true" ]; then
echo 'g++ -g -fPIC -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32  -Werror  -O0 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH//BRAHMS/bin" -lbrahms-engine' &amp;> $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/build
else
echo 'g++ -fPIC -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32  -Werror  -O3 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH//BRAHMS/bin" -lbrahms-engine' &amp;> $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/build
fi
cd $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi
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
DIRNAME=$BRAHMS_NS/dev/SpineML/temp/WU/<xsl:value-of select="local-name(SMLNL:ConnectionList)"/><xsl:value-of select="local-name(SMLNL:FixedProbabilityConnection)"/><xsl:value-of select="local-name(SMLNL:AllToAllConnection)"/><xsl:value-of select="local-name(SMLNL:OneToOneConnection)"/><xsl:value-of select="translate(document(SMLLOWNL:WeightUpdate/@url)//SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
#if [ -d "$DIRNAME" ]; then
diff -q ../model/<xsl:value-of select="$wu_url"/> $DIRNAME/<xsl:value-of select="$wu_url"/> &amp;> /dev/null
if [ $? == 0 ]; then
LA="moo"
#echo "Weight Update component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping"
else
xsltproc -o component.cpp ../xsl/LL/SpineML_2_BRAHMS_CL_weight.xsl ../model/<xsl:value-of select="$model_xml"/>
echo "Building weight update component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/>"
mkdir -p $DIRNAME
cp ../model/<xsl:value-of select="$wu_url"/> ./component.cpp ../include/rng.h ../include/impulse.h $DIRNAME/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $DIRNAME/release.xml
if [ $DEBUG = "true" ]; then
echo 'g++ -g -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -Werror  -O0 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH/BRAHMS/bin" -lbrahms-engine' &amp;> $DIRNAME/build
cd $DIRNAME/
else 
echo 'g++ -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -Werror  -O3 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH/BRAHMS/bin" -lbrahms-engine' &amp;> $DIRNAME/build
cd $DIRNAME/
fi
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi

DIRNAME=$BRAHMS_NS/dev/SpineML/temp/PS/<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass"><xsl:value-of select="translate(@name,' -', 'oH')"/>
</xsl:for-each>/brahms/0
#if [ -d "$DIRNAME" ]; then
diff -q ../model/<xsl:value-of select="$ps_url"/> $DIRNAME/<xsl:value-of select="$ps_url"/> &amp;> /dev/null
if [ $? == 0 ]; then
LA="moo"
#echo "PostSynapse component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping"
else
xsltproc -o component.cpp ../xsl/LL/SpineML_2_BRAHMS_CL_postsyn.xsl ../model/<xsl:value-of select="$model_xml"/>
echo "Building postsynapse component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/>"
mkdir -p $DIRNAME
cp ../model/<xsl:value-of select="$ps_url"/> ./component.cpp ../include/rng.h ../include/impulse.h $DIRNAME/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $DIRNAME/release.xml
if [ $DEBUG = "true" ]; then
echo 'g++ -g -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -Werror  -O0 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH/BRAHMS/bin" -lbrahms-engine' &amp;> $DIRNAME/build
cd $DIRNAME/
else
echo 'g++ -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -Werror  -O3 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH/BRAHMS/bin" -lbrahms-engine' &amp;> $DIRNAME/build
cd $DIRNAME/
fi
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file2/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi
<!-- MORE HERE -->

		</xsl:for-each>
	</xsl:for-each>
</xsl:for-each>
echo "Building the system..."
xsltproc -o sys.xml ../xsl/LL/SpineML_2_BRAHMS_NL.xsl ../model/$INPUT
echo "Building the execution..."
xsltproc -o sys-exe.xml ../xsl/LL/SpineML_2_BRAHMS_EXPT.xsl ../model/$INPUT
echo "Done!"

# run!
echo "Running!"
#chmod +x brahms_launch

brahms --par-NamespaceRoots=$BRAHMS_NS:../tools sys-exe.xml

</xsl:when>
<xsl:when test="SMLNL:SpineML">

#!/bin/bash
INPUT=$1
REBUILD=$2
BRAHMS_NS=$3
# exit on first error
set -e
if [ $REBUILD = "true" ]; then
# clean up the temporary dirs - we don't want old component versions lying around!
rm -R $BRAHMS_NS/dev/SpineML/temp/*
fi
echo "Creating the Neuron populations..."
<xsl:for-each select="/SMLNL:SpineML/SMLNL:Population">
<xsl:choose>
<xsl:when test="./SMLNL:Neuron/@url = 'SpikeSource'">
echo "SpikeSource, skipping compile"
</xsl:when>
<xsl:otherwise>
<xsl:variable name="linked_file" select="document(./SMLNL:Neuron/@url)"/>
<!-- Here we use the population number to determine which Neuron type we are outputting -->
<xsl:variable name="number"><xsl:number count="/SMLNL:SpineML/SMLNL:Population" format="1"/></xsl:variable>
echo "&lt;Number&gt;<xsl:value-of select="$number"/>&lt;/Number&gt;" &amp;&gt; counter.file
DIRNAME=$BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
#if [ -d "$DIRNAME" ]; then
diff -q ../model/<xsl:value-of select="./SMLNL:Neuron/@url"/> $DIRNAME/<xsl:value-of select="./SMLNL:Neuron/@url"/> &amp;> /dev/null
if [ $?  == 0 ]; then
echo "Component for population <xsl:value-of select="$number"/> exists, skipping"
else
xsltproc -o component.cpp ../xsl/HL/SpineML_2_BRAHMS_CL_neurons.xsl ../model/<xsl:value-of select="$model_xml"/>
echo "Building component for population <xsl:value-of select="$number"/>"
mkdir -p $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
cp ../model/<xsl:value-of select="./SMLNL:Neuron/@url"/> ./component.cpp ../include/rng.h ../include/impulse.h $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/release.xml

echo 'g++ -fPIC -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32  -Werror  -O3 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH//BRAHMS/bin" -lbrahms-engine' &amp;> $BRAHMS_NS/dev/SpineML/temp/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/build
cd $BRAHMS_NS/dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0/
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
echo "Creating the projections..."
<xsl:for-each select="/SMLNL:SpineML/SMLNL:Population">
<!-- Here we use the population number to determine which pop the projection belongs to -->
<xsl:variable name="number1"><xsl:number count="/SMLNL:SpineML/SMLNL:Population" format="1"/></xsl:variable>
	<xsl:variable name="src" select="@name"/>
	<xsl:for-each select=".//SMLNL:Projection">
<!-- Here we use the Synapse number to determine which pop the projection targets -->
<xsl:variable name="number2"><xsl:number count="//SMLNL:Projection" format="1"/></xsl:variable>
                <xsl:variable name="dest" select="@dst_population"/>
		<xsl:for-each select=".//SMLNL:Synapse">
<!-- Here we use the target number to determine which WeightUpdate the projection targets -->
<xsl:variable name="number3"><xsl:number count="//SMLNL:Synapse" format="1"/></xsl:variable>
echo "&lt;Nums&gt;&lt;Number1&gt;<xsl:value-of select="$number1"/>&lt;/Number1&gt;&lt;Number2&gt;<xsl:value-of select="$number2"/>&lt;/Number2&gt;&lt;Number3&gt;<xsl:value-of select="$number3"/>&lt;/Number3&gt;&lt;/Nums&gt;" &amp;&gt; counter.file

<xsl:variable name="linked_file" select="document(SMLNL:WeightUpdate/@url)"/>
<xsl:variable name="linked_file2" select="document(SMLNL:PostSynapse/@url)"/>
<xsl:variable name="wu_url" select="SMLNL:WeightUpdate/@url"/>
<xsl:variable name="ps_url" select="SMLNL:PostSynapse/@url"/>
DIRNAME=$BRAHMS_NS/dev/SpineML/temp/WU/<xsl:value-of select="local-name(SMLNL:ConnectionList)"/><xsl:value-of select="local-name(SMLNL:FixedProbabilityConnection)"/><xsl:value-of select="local-name(SMLNL:AllToAllConnection)"/><xsl:value-of select="local-name(SMLNL:OneToOneConnection)"/><xsl:value-of select="translate(document(SMLNL:WeightUpdate/@url)//SMLCL:ComponentClass/@name,' -', 'oH')"/>/brahms/0
diff -q ../model/<xsl:value-of select="$wu_url"/> $DIRNAME/<xsl:value-of select="$wu_url"/> &amp;> /dev/null
if [ $?  == 0 ]; then
LA="moo"
#echo "Weight Update component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping"
else
xsltproc -o component.cpp ../xsl/HL/SpineML_2_BRAHMS_CL_weight.xsl ../model/<xsl:value-of select="$model_xml"/>
echo "Building weight update component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/>"
mkdir -p $DIRNAME
cp ../model/<xsl:value-of select="$wu_url"/> ./component.cpp ../include/rng.h ../include/impulse.h $DIRNAME/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $DIRNAME/release.xml

echo 'g++ -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -Werror  -O3 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH/BRAHMS/bin" -lbrahms-engine' &amp;> $DIRNAME/build
cd $DIRNAME/
echo "&lt;Node&gt;&lt;Type&gt;Process&lt;/Type&gt;&lt;Specification&gt;&lt;Connectivity&gt;&lt;InputSets&gt;<xsl:for-each select="$linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort | $linked_file/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">&lt;Set&gt;<xsl:value-of select="@name"/>&lt;/Set&gt;</xsl:for-each>&lt;/InputSets&gt;&lt;/Connectivity&gt;&lt;/Specification&gt;&lt;/Node&gt;" &amp;> ../../node.xml
chmod +x build
./build
cd - &amp;&gt; /dev/null
fi

DIRNAME=$BRAHMS_NS/dev/SpineML/temp/PS/<xsl:for-each select="$linked_file2/SMLCL:SpineML/SMLCL:ComponentClass"><xsl:value-of select="translate(@name,' -', 'oH')"/>
</xsl:for-each>/brahms/0
diff -q ../model/<xsl:value-of select="$ps_url"/> $DIRNAME/<xsl:value-of select="$ps_url"/> &amp;> /dev/null
if [ $?  == 0 ]; then
LA="moo"
#echo "PostSynapse component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/> exists, skipping"
else
xsltproc -o component.cpp ../xsl/HL/SpineML_2_BRAHMS_CL_postsyn.xsl ../model/<xsl:value-of select="$model_xml"/>
echo "Building postsynapse component for population <xsl:value-of select="$number1"/>, projection <xsl:value-of select="$number2"/>, synapse <xsl:value-of select="$number3"/>"
mkdir -p $DIRNAME
cp ../model/<xsl:value-of select="$ps_url"/> ./component.cpp ../include/rng.h ../include/impulse.h $DIRNAME/
echo "&lt;Release&gt;&lt;Language&gt;1199&lt;/Language&gt;&lt;/Release&gt;" &amp;> $DIRNAME/release.xml

echo 'g++ -fvisibility=hidden -fvisibility-inlines-hidden -arch x86_64 -D__OSX__ -DARCH_BITS=32 -fPIC -Werror  -O3 -ffast-math  -dynamiclib -arch i386 -D__OSX__ component.cpp -o component.dylib -I"$SYSTEMML_INSTALL_PATH/BRAHMS/include" -I"$SYSTEMML_INSTALL_PATH/Namespace" -L"$SYSTEMML_INSTALL_PATH/BRAHMS/bin" -lbrahms-engine' &amp;> $DIRNAME/build
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
echo "Building the system..."
xsltproc -o sys.xml ../xsl/HL/SpineML_2_BRAHMS_NL.xsl ../model/$INPUT
echo "Building the execution..."
xsltproc -o sys-exe.xml ../xsl/HL/SpineML_2_BRAHMS_EXPT.xsl ../model/$INPUT
echo "Done!"

# run!
echo "Running!"
#chmod +x brahms_launch

brahms --par-NamespaceRoots=$BRAHMS_NS:../tools sys-exe.xml


</xsl:when>
<xsl:otherwise>
echo "ERROR: Unrecognised SpineML Network Layer file";
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>

</xsl:stylesheet>


