<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:OnImpulse" mode="doImpulseInputs">
					// template match="SMLCL:OnImpulse" mode="doImpulseInputs"<!---->
					<xsl:text>
					</xsl:text>
					<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regimeNext[num_BRAHMS]=<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@target_regime"/>;
					<!-- if is an event driven component -->
					<xsl:if test="count(//SMLCL:TimeDerivative | SMLCL:AnalogReceivePort | SMLCL:AnalogReducePort | SMLCL:AnalogSendPort) = 0">
						<xsl:apply-templates select="//SMLCL:Alias" mode="doPortAssignments"/>
					</xsl:if>
					<xsl:apply-templates/>
</xsl:template>

<xsl:include href="SpineML_StateAssignment.xsl"/>
<xsl:include href="SpineML_EventOut.xsl"/>
</xsl:stylesheet>
