<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- START TEMPLATE -->
<xsl:template name="networkLayerExternalOutputs">

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- ENTER THE EXPERIMENT FILE -->
<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
<xsl:variable name="main_root" select="/"/>


<xsl:for-each select="$expt_root//SMLEXPT:Experiment//SMLEXPT:LogOutput[@tcp_port]">
<!-- ADD THE INPUT PROCESS ############################ -->
<Process>
	<Name><xsl:value-of select="concat('output',generate-id(.))"/></Name>
	<Class>
			<xsl:text>dev/SpineML/tools/externalOutput</xsl:text>
	</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">
	<!-- TCP/IP PORT; COMPONENT PORT TYPE -->
	<xsl:text>port;type;</xsl:text>
	<!-- LOG, WHERE NOT LOGGING 'ALL' -->
	<xsl:if test="self::node()[@indices]">
		<!---->logInds;<!---->
	</xsl:if>
	<xsl:if test="self::node()[not(@indices)]">
		<!---->logAll;<!---->
	</xsl:if>
    <!-- A FILENAME FOR LOGGING -->
    <!---->logfileNameForComponent;<!---->
	</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<!-- TCP/IP PORT -->
	<m c="f"><xsl:value-of select="@tcp_port"/></m>
	<!-- WHAT KIND OF INPUT SHOULD WE EXPECT? -->
	<xsl:variable name="target" select="@target"/>
	<xsl:variable name="port" select="@port"/>
	<!-- ANALOG -->
	<xsl:if test="document($main_root//*[@name=$target]/@url)//SMLCL:AnalogSendPort[@name=$port]">
		<m c="f">0</m>
	</xsl:if>
	<!-- EVENT -->
	<xsl:if test="document($main_root//*[@name=$target]/@url)//SMLCL:EventSendPort[@name=$port]">
		<m c="f">1</m>
	</xsl:if>
	<!-- IMPULSE -->
	<xsl:if test="document($main_root//*[@name=$target]/@url)//SMLCL:ImpulseSendPort[@name=$port]">
		<m c="f">2</m>
	</xsl:if>
	<!-- LOGS, WHERE NOT LOGGING 'ALL' -->
	<xsl:if test="self::node()[@indices]">
		<m><xsl:attribute name="b">1 <!---->
    		<xsl:call-template name="count_array_items">
    			<xsl:with-param name="items" select="@indices"/>
    		</xsl:call-template>
    	</xsl:attribute>
    	<xsl:attribute name="c">f</xsl:attribute>
		<xsl:value-of select="translate(@indices,',',' ')"/>
    	</m>
    </xsl:if>
    <xsl:if test="self::node()[not(@indices)]">
		<m>
		<xsl:attribute name="b">
			<!---->1<!---->	
    	</xsl:attribute>
    	<xsl:attribute name="c">f</xsl:attribute>
			<!---->1<!---->	
    	</m>
    </xsl:if>
    <!-- NAME FOR USE IN LOGS -->
    <m><xsl:value-of select="translate(@target,' ', '_')"/></m>
	</State>
</Process>

<!-- ADD THE OUTPUT LINK ############################ -->
<Link>
    <Src><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@port"/></Src>
    <Dst><xsl:value-of select="concat('output',generate-id(.))"/>&lt;in</Dst>
	<Lag>0</Lag>
</Link>

</xsl:for-each>


<!-- EXIT THE EXPERIMENT FILE -->
</xsl:for-each>

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
