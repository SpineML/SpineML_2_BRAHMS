<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- START TEMPLATE -->
<xsl:template name="networkLayerExternalInputs">

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- ENTER THE EXPERIMENT FILE -->
<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
<xsl:variable name="main_root" select="/"/>

<!-- MAIN CODE - NOTE THIS ONLY CURRENTLY WORKS FOR ANALOG INPUTS... -->

<xsl:for-each select="$expt_root//SMLEXPT:Experiment/SMLEXPT:ExternalInput">
	<!-- ADD INPUT PROCESS -->
    <Process>
    	<!-- GENERATE A UNIQUE NAME FOR THE INPUT PROCESS -->
        <Name><xsl:value-of select="concat('input',generate-id(.))"/></Name>
        <Class>
            <xsl:text>dev/SpineML/tools/externalInput</xsl:text>
        </Class>
        <Time>
            <SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
        </Time>
        <!-- STATE DATA -->
        <State>
            <xsl:attribute name="c">z</xsl:attribute>
            <xsl:attribute name="a">
                <xsl:text>port;size;</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="Format">DataML</xsl:attribute>
            <xsl:attribute name="Version">5</xsl:attribute>
            <xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
            <xsl:attribute name="AuthToolVersion">0</xsl:attribute>
            <m c="f"><xsl:value-of select="@tcp_port"/></m>
            <m c="f"><xsl:value-of select="@size"/></m>
        </State>
    </Process>
    <xsl:variable name="dstPortRef" select="@port"/>
    <xsl:variable name="target" select="@target"/>
    <xsl:variable name="targetFile" select="document($main_root//*[@name = $target]/@url)"/>
    <!-- LINK TO TARGET -->
    <Link>
        <Src><xsl:value-of select="concat('input',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <!-- SET DEST BASED ON WHAT WE ARE INPUTING TO -->
        <xsl:if test="$main_root//*[@name = $target]/@url='SpikeSource'">
        	<!-- NOT SUPPORTED -->
        	<xsl:message terminate="true">
        		<!---->Error: Event external inputs are not currently supported by BRAHMS, sorry!<!---->
        	</xsl:message>
        </xsl:if>
        <Dst><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:if test="count($targetFile//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@port"/></Dst>
        <Lag>0</Lag>
    </Link>
</xsl:for-each>




<!-- EXIT THE EXPERIMENT FILE -->
</xsl:for-each>

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
