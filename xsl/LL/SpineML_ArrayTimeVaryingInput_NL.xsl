<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- START TEMPLATE -->
<xsl:template name="networkLayerArrayTimeVaryingInputs">

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- ENTER THE EXPERIMENT FILE -->
<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
<xsl:variable name="main_root" select="/"/>


<!-- OLD CODE BELOW - COMMENTING MAY BE SPORADIC -->


<xsl:for-each select="$expt_root//SMLEXPT:Experiment/SMLEXPT:TimeVaryingArrayInput">
<Process>
	<Name><xsl:value-of select="concat('input',generate-id(.))"/></Name>
	<Class>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>dev/SpineML/tools/EventTimeVaryingInput</xsl:text>
		</xsl:if>
		<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
			<xsl:text>dev/SpineML/tools/AnalogTimeVaryingInput</xsl:text>
		</xsl:if>
	</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">
		<xsl:for-each select="SMLEXPT:TimePointArrayValue">
			<xsl:value-of select="concat('values',@index)"/>;<!---->
		</xsl:for-each>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>rateType;size;</xsl:text>
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
	<xsl:for-each select="SMLEXPT:TimePointArrayValue">
	<m>
		<xsl:attribute name="b">2 <xsl:call-template name="count_array_items"><xsl:with-param name="items" select="@array_value"/></xsl:call-template></xsl:attribute>
		<xsl:attribute name="c">f</xsl:attribute>
		<xsl:value-of select="translate(@array_time,',',' ')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="translate(@array_value,',',' ')"/>
		<xsl:text> </xsl:text>
	</m>
	</xsl:for-each>
	<xsl:if test="@rate_based_input='poisson'">
		<m c="f">0</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='regular'">
		<m c="f">1</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
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
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="input_id" select="generate-id(.)"/>
<!--IF NOT SPIKING -->
<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
	<xsl:variable name="targetFile" select="document($main_root//*[@name = $target]/@url)"/>
	<Link>
		<Src><xsl:value-of select="concat('input',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
		<Dst><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:if test="count($targetFile//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@port"/></Dst>
		<Lag>0</Lag>
	</Link>
</xsl:if>
<!--IF SPIKING -->
<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
	<xsl:for-each select="$main_root//SMLLOWNL:Neuron[@name=$target]/..//SMLLOWNL:WeightUpdate">
	<Link>
		<Src><xsl:value-of select="concat('input',$input_id)"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
		<Dst><xsl:value-of select="translate(@name,' -', '_H')"/>&lt;&lt;<xsl:value-of select="@input_dst_port"/></Dst>
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
