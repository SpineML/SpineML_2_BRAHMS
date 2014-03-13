<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Regime" mode="defineTimeDerivFuncs">
<xsl:apply-templates select="SMLCL:TimeDerivative" mode="defineTimeDerivFuncs"/>
</xsl:template>

<xsl:template match="SMLCL:Regime" mode="defineTimeDerivFuncsPtr">
<xsl:apply-templates select="SMLCL:TimeDerivative" mode="defineTimeDerivFuncsPtr"/>
</xsl:template>

<xsl:template match="SMLCL:Regime" mode="defineTimeDerivFuncsPtr1">
<xsl:apply-templates select="SMLCL:TimeDerivative" mode="defineTimeDerivFuncsPtr1"/>
</xsl:template>


<xsl:template match="SMLCL:Regime" mode="defineRegime">
#define <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/><xsl:text> </xsl:text><xsl:number count="SMLCL:Regime" from="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics" format="1"/> </xsl:template>

<xsl:template match="SMLCL:Regime" mode="doTrans">
					//Regime
					case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
					{
	<xsl:apply-templates select="SMLCL:OnCondition" mode="evalTrans"/>
	<xsl:apply-templates select="SMLCL:OnCondition" mode="doTrans"/>
					}
					break;
</xsl:template>

<xsl:template match="SMLCL:Regime" mode="doIter">
					//Regime
					case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
					{
	<xsl:apply-templates select="SMLCL:TimeDerivative" mode="doIter"/>
	<xsl:apply-templates select="SMLCL:TimeDerivative" mode="assignIterVal"/>
					}
					break;
</xsl:template>


<xsl:include href="SpineML_TimeDerivative.xsl"/>
<xsl:include href="SpineML_OnEvent.xsl"/>
<xsl:include href="SpineML_OnCondition.xsl"/>
<xsl:include href="SpineML_Alias.xsl"/>

</xsl:stylesheet>
