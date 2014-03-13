<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Alias" mode="doPortAssignments">
					//Alias assignment for ports
					<xsl:value-of select="@name"/>[num]=<xsl:call-template name="alias_replace">
                                                        <xsl:with-param name="params" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Parameter | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReceivePort"/>
                                                        <xsl:with-param name="aliases" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias"/>
                                                        <xsl:with-param name="string" select="SMLCL:MathInline"/>
					</xsl:call-template>;
</xsl:template>

<xsl:template match="SMLCL:Alias" mode="resizeAlias">
					//resize Aliases
					<xsl:value-of select="@name"/>.resize(numEl, 0);
</xsl:template>

<xsl:template match="SMLCL:Alias" mode="defineAlias">
vector &lt; double &gt; <xsl:value-of select="@name"/>; 
</xsl:template>

</xsl:stylesheet>
