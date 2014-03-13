<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 

xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>
<!--

Ok, here we make an execution file from the Experiment file

-->
<xsl:template match="/">

<Execution Version="1.0" AuthTool="SpineML to BRAHMS XSLT translator" AuthToolVersion="1.0">
	<Title>SpineML Experiment</Title>
	<SystemFileIn>sys.xml</SystemFileIn>
	<SystemFileOut/>
	<ReportFile>rep-((VOICE)).xml</ReportFile>
	<WorkingDirectory/>
	<ExecutionStop><xsl:value-of select="//SMLEXPT:Simulation/@duration"/></ExecutionStop>
	<Seed/>
	<Logs Encapsulated="0" Precision="6" All="0">
		<xsl:for-each select="//SMLEXPT:LogOutput">
		<Log><xsl:value-of select="translate(@target,' ', '_')"/><xsl:text disable-output-escaping="yes">>>></xsl:text><xsl:value-of select="@port"/></Log>
		</xsl:for-each>
	</Logs>
	<Voices>
	<Voice/>
	</Voices>
	<Affinity/>
	<ExecutionParameters>
	<MaxThreadCount>x4</MaxThreadCount>
	</ExecutionParameters>
</Execution>
</xsl:template>

</xsl:stylesheet>


