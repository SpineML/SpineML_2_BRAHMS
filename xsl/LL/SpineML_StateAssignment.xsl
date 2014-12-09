<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:StateAssignment">				//StateAssignment
					<xsl:value-of select="@variable"/>[num_BRAHMS] = <xsl:call-template name="alias_replace"><xsl:with-param name="aliases" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias"/>
<xsl:with-param name="params" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Parameter | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReceivePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort"/><xsl:with-param name="string" select="SMLCL:MathInline"/></xsl:call-template>; </xsl:template>
</xsl:stylesheet>
