<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer"
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer"
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- The template provided by this file creates a SystemML <Process>
     which provides a constant input source. It also generates some
     <Link>s. The output from this file finds its way into sys.xml -->

<!-- START TEMPLATE -->
<xsl:template name="networkLayerConstantInputs">

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- ENTER THE EXPERIMENT FILE -->
<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
<xsl:variable name="main_root" select="/"/>


<!-- OLD CODE BELOW - COMMENTING MAY BE SPORADIC -->

<xsl:for-each select="$expt_root//SMLEXPT:Experiment/SMLEXPT:ConstantInput">
<!-- ADD THE INPUT PROCESS ############################ -->
<Process>
	<Name><xsl:value-of select="concat('input',generate-id(.))"/></Name>
	<Class>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>dev/SpineML/tools/EventConstantInput</xsl:text>
		</xsl:if>
		<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
			<xsl:text>dev/SpineML/tools/AnalogConstantInput</xsl:text>
		</xsl:if>
	</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">
		<xsl:text>values;</xsl:text>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>rateType;rateSeed;size;</xsl:text>
			<!-- LOG, WHERE NOT LOGGING 'ALL' -->
			<xsl:variable name="target" select="@target"/>
			<xsl:for-each select="$expt_root//SMLEXPT:LogOutput[@indices and @target=$target]">
				<xsl:value-of select="concat(@port,'LOG')"/>
				<!---->;<!---->
			</xsl:for-each>
			<xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@indices) and @target=$target]">
				<xsl:value-of select="concat(@port,'LOGALL')"/>
				<!---->;<!---->
			</xsl:for-each>
        <!-- A FILENAME FOR LOGGING -->
        <!---->logfileNameForComponent;<!---->
		</xsl:if>
		</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m b="1" c="f"><xsl:value-of select="@value"/></m>
	<xsl:if test="@rate_based_input='poisson'">
		<m c="f">0</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='regular'">
		<m c="f">1</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
		<xsl:if test="@rate_seed">
			<m c="f"><xsl:value-of select="@rate_seed"/></m>
		</xsl:if>
		<xsl:if test="not(@rate_seed)">
			<m c="f">123</m>
		</xsl:if>
		<m c="f">
		<!-- size of source -->
		<xsl:variable name="target" select="@target"/>
		<xsl:value-of select="$main_root//*[@name = $target]/@size"/>
		</m>
		<!-- LOGS, WHERE NOT LOGGING 'ALL' -->
		<xsl:variable name="target" select="@target"/>
   		<xsl:for-each select="$expt_root//SMLEXPT:LogOutput[@indices and @target=$target]">
			<m><xsl:attribute name="b">1 <!---->
        		<xsl:call-template name="count_array_items">
        			<xsl:with-param name="items" select="@indices"/>
        		</xsl:call-template>
        	</xsl:attribute>
        	<xsl:attribute name="c">f</xsl:attribute>
			<xsl:value-of select="translate(@indices,',',' ')"/>
        	</m>
        </xsl:for-each>
        <xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@indices) and @target=$target]">
			<m>
			<xsl:attribute name="b">
				<!---->1<!---->
        	</xsl:attribute>
        	<xsl:attribute name="c">f</xsl:attribute>
				<!---->1<!---->
        	</m>
        </xsl:for-each>
        <!-- NAME FOR USE IN LOGS -->
        <m><xsl:value-of select="translate(@target,' ', '_')"/></m>
	</xsl:if>
	</State>
</Process>

<!-- ADD THE INPUT LINKS AND REMAPPING ############################ -->

<!-- IF NOT EVENT ################################## -->
<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="targetFile" select="document($main_root//*[@name = $target]/@url)"/>

<!-- SIZE OUT FOR REMAP -->
<xsl:variable name="sizeOut">
<xsl:for-each select="$main_root//*[@name = $target]">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:Connection//SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:value-of select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../../../../SMLLOWNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:Connection)>0">
                <xsl:value-of select="count(../SMLNL:Connection//SMLNL:Connection)"/>
	</xsl:if>
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLLOWNL:SpineML//SMLLOWNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>
<!-- END SIZE OUT FOR REMAP -->

<!-- ADD REMAP -->
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
	<m c="f"><xsl:value-of select="'1'"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	</State>
</Process>
<Link>
    <Src><xsl:value-of select="concat('input',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        <xsl:text disable-output-escaping="no">&lt;inSpike</xsl:text>
        </xsl:if>
        <xsl:if test="count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=0">
        <xsl:text disable-output-escaping="no">&lt;in</xsl:text>
        </xsl:if>
        </Dst>
	<Lag>0</Lag>
</Link>
<Link>
    <Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
    <Dst><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:if test="count($targetFile//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@port"/></Dst>
	<Lag>0</Lag>
</Link>

</xsl:if>

<!-- IF EVENT ################################## -->
<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
<xsl:variable name="idString" select="generate-id(.)"/>
<xsl:variable name="target" select="@target"/>

<!-- EACH SYNAPSE OUT FROM THE SOURCE NEEDS A 1-2-1 CONNECTION (COULD DO OTHERWISE FOR REGULAR SPIKES...) -->
<xsl:for-each select="$main_root//SMLLOWNL:Population[SMLLOWNL:Neuron/@name=$target]//SMLLOWNL:Synapse">
<Link>
    <Src><xsl:value-of select="concat('input',$idString)"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
    <Dst><xsl:value-of select="translate(SMLLOWNL:WeightUpdate/@name,' -', '_H')"/>&lt;&lt;<xsl:value-of select="SMLLOWNL:WeightUpdate/@input_dst_port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:for-each>
</xsl:if>
</xsl:for-each>



<!-- EXIT THE EXPERIMENT FILE -->
</xsl:for-each>

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
