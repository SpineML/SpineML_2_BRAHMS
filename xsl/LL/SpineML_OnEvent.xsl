<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:OnEvent" mode="doEventInputs">
					//OnEvent1
					<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regimeNext[num_BRAHMS]=<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@target_regime"/>;
					<!-- if is an event driven component -->
					<xsl:if test="count(//SMLCL:TimeDerivative | SMLCL:AnalogReceivePort | SMLCL:AnalogReducePort) = 0">
						<xsl:apply-templates select="//SMLCL:Alias" mode="doPortAssignments"/>
					</xsl:if>
					<xsl:apply-templates/>
					<xsl:text>
					</xsl:text>
</xsl:template>


<xsl:include href="SpineML_StateAssignment.xsl"/>
<xsl:include href="SpineML_ImpulseOut.xsl"/>

</xsl:stylesheet>
