<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Alias" mode="doPortAssignments">
					//Alias assignment for ports
					<xsl:value-of select="@name"/>[num_BRAHMS]=<xsl:call-template name="alias_replace">
                                                        <xsl:with-param name="params" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Parameter | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReceivePort"/>
                                                        <xsl:with-param name="aliases" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias"/>
                                                        <xsl:with-param name="string" select="SMLCL:MathInline"/>
					</xsl:call-template>;
</xsl:template>

<xsl:template match="SMLCL:Alias" mode="resizeAlias">
			<xsl:if test="@name=//SMLCL:AnalogSendPort/@name">
				<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
			</xsl:if>
</xsl:template>

<xsl:template match="SMLCL:Alias" mode="defineAlias">
<xsl:if test="@name=//SMLCL:AnalogSendPort/@name">
vector &lt; double &gt; <xsl:value-of select="@name"/>;
</xsl:if>
</xsl:template>

</xsl:stylesheet>
