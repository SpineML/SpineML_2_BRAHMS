<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- This template generates SystemML <Process> components and
     associated <Links> for generic inputs. Its output makes it into
     sys.xml -->

<!-- START TEMPLATE -->
<xsl:template name="networkLayerGenericInputs">

<xsl:param name="spineml_2_brahms_dir" select="'../../'"/>

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- ENTER THE EXPERIMENT FILE -->
<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
<xsl:variable name="main_root" select="/"/>


<!-- OLD CODE BELOW - COMMENTING MAY BE SPORADIC -->

<!-- ############### GENERIC INPUTS ############### -->

<xsl:for-each select="//SMLLOWNL:Input">
<xsl:variable name="dstPortRef" select="@dst_port"/>

<xsl:variable name="target_name" select="../../@dst_population"/>
<xsl:variable name="source_name" select="../../../SMLLOWNL:Neuron/@name"/>

<!-- APPLY LESION -->
<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

<!-- UNSUPPORTED -->
<xsl:if test="count(.//SMLNL:FixedValue)=0">
	<xsl:message terminat="yes">Only Fixed delays for generic inputs currently supported for BRAHMS</xsl:message>
</xsl:if>

<xsl:variable name="sizeIn">
<xsl:variable name="srcObjName" select="@src"/>
<xsl:for-each select="//*[@name=$srcObjName]">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../@dst_population"/>
                <xsl:value-of select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[@name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[@name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../SMLLOWNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:ConnectionList)>0">
                <xsl:value-of select="count(../SMLNL:ConnectionList/SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[@name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>

<xsl:variable name="sizeOut">

<xsl:variable name="dstportactual" select="document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef] | document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef] | document(../@url)//SMLCL:AnalogReceivePort[@name=$dstPortRef] | document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef]"/>
<xsl:for-each select="..">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
  <xsl:if test="count(../SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../@dst_population"/>
                <xsl:value-of select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[@name=$ownerPopName]/@size"/>
	</xsl:if>
  <xsl:if test="count(../SMLNL:AllToAllConnection)=1">
    <xsl:variable name="ownerPopName" select="../../@dst_population"/>
    <xsl:variable name="dstPopSize" select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[@name=$ownerPopName]/@size"/>
    <xsl:variable name="srcPopSize" select="../../../SMLLOWNL:Neuron/@size"/>
    <xsl:if test="$dstportactual/@post">
    <xsl:value-of select="number($dstPopSize)"/>
    </xsl:if>
    <xsl:if test="not($dstportactual/@post)">
		<xsl:value-of select="number($srcPopSize)"/>
		</xsl:if>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection)>0">
                <xsl:value-of select="count(../SMLNL:Connection//SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[@name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>

<xsl:if test="count(.//SMLNL:AllToAllConnection)=1">
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/allToAll</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeIn"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	</State>
</Process>
<Link>
        <Src>
        <xsl:value-of select="translate(@src,' -', '_H')"/>
        <xsl:text disable-output-escaping="no">&gt;</xsl:text>
        <xsl:value-of select="@src_port"/></Src>
        <Dst>
        <xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inSpike<!---->
	</xsl:if>
        <xsl:if test="count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inImpulse<!---->
	</xsl:if>
	<xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=0 and count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=0">
		<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->in<!---->
	</xsl:if>
	</Dst>
        <Lag><xsl:if test="count(.//SMLNL:FixedValue)=1 and not(number(.//SMLNL:FixedValue/@value)=0)"><xsl:value-of select="number(.//SMLNL:FixedValue/@value) div $expt_root//@dt"/></xsl:if><xsl:if test="not(count(.//SMLNL:FixedValue)=1) or number(.//SMLNL:FixedValue/@value)=0">1</xsl:if></Lag>
</Link>
<Link>
	<Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef]) or count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:if>



<xsl:if test="count(.//SMLNL:OneToOneConnection)=1">

<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef]) or count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag><xsl:if test="count(.//SMLNL:FixedValue)=1 and not(number(.//SMLNL:FixedValue/@value)=0)"><xsl:value-of select="number(.//SMLNL:FixedValue/@value) div $expt_root//@dt"/></xsl:if><xsl:if test="not(count(.//SMLNL:FixedValue)=1) or number(.//SMLNL:FixedValue/@value)=0">1</xsl:if></Lag>
</Link>
</xsl:if>



<xsl:if test="count(.//SMLNL:FixedProbabilityConnection)=1">
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/fixedProbability</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;p;seed;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeIn"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	<m c="f"><xsl:value-of select="@probability"/></m>
	<m c="f"><xsl:value-of select="@seed"/></m>
	</State>
</Process>
<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst>
        <xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inSpike<!---->
	</xsl:if>
        <xsl:if test="count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inImpulse<!---->
	</xsl:if>
	<xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=0 and count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=0">
		<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->in<!---->
	</xsl:if>
        </Dst>
        <Lag><xsl:if test="count(.//SMLNL:FixedValue)=1 and not(number(.//SMLNL:FixedValue/@value)=0)"><xsl:value-of select="number(.//SMLNL:FixedValue/@value) div $expt_root//@dt"/></xsl:if><xsl:if test="not(count(.//SMLNL:FixedValue)=1) or number(.//SMLNL:FixedValue/@value)=0">1</xsl:if></Lag>
</Link>
<Link>
	<Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:if>



<xsl:if test="count(.//SMLNL:ConnectionList)=1">
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/explicitList</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;binpath;<xsl:if test="./SMLNL:ConnectionList/SMLNL:BinaryFile">_bin_file_name;_bin_num_conn;_bin_has_delay;</xsl:if><xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Connection)>0">src;dst;</xsl:if></xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeIn"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	<m><xsl:value-of select="$spineml_model_dir"/>/</m>
	<xsl:if test="./SMLNL:ConnectionList/SMLNL:BinaryFile">
		<m><xsl:value-of select="./SMLNL:ConnectionList/SMLNL:BinaryFile/@file_name"/></m>
		<m c="f"><xsl:value-of select="./SMLNL:ConnectionList/SMLNL:BinaryFile/@num_connections"/></m>
		<m c="f"><xsl:value-of select="./SMLNL:ConnectionList/SMLNL:BinaryFile/@explicit_delay_flag"/></m>
	</xsl:if>
	<xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Connection)>0">
        <m><xsl:attribute name="b">1 <xsl:value-of select="count(.//SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
        <xsl:for-each select=".//SMLNL:Connection"><xsl:value-of select="@src_neuron"/><xsl:text> </xsl:text></xsl:for-each>
	</m>
        <m><xsl:attribute name="b">1 <xsl:value-of select="count(.//SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
        <xsl:for-each select=".//SMLNL:Connection"><xsl:value-of select="@dst_neuron"/><xsl:text> </xsl:text></xsl:for-each>
	</m>
	</xsl:if>
	</State>
</Process>
<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst>
        <xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inSpike<!---->
	</xsl:if>
        <xsl:if test="count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inImpulse<!---->
	</xsl:if>
	<xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=0 and count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=0">
		<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->in<!---->
	</xsl:if>
        </Dst>
        <Lag><xsl:if test="count(.//SMLNL:FixedValue)=1 and not(number(.//SMLNL:FixedValue/@value)=0)"><xsl:value-of select="number(.//SMLNL:FixedValue/@value) div $expt_root//@dt"/></xsl:if><xsl:if test="not(count(.//SMLNL:FixedValue)=1) or number(.//SMLNL:FixedValue/@value)=0">1</xsl:if></Lag>
</Link>
<Link>
	<Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:if>


<xsl:if test="count(./*)=0">
<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>1</Lag>
</Link>
</xsl:if>

</xsl:if>
</xsl:for-each> 
<!-- END OF INPUTS -->



<!-- EXIT THE EXPERIMENT FILE -->
</xsl:for-each>

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
