<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:OnCondition" mode="evalTrans">
					bool trans<xsl:value-of name="thisTrans" select="generate-id(.)"/> = false;
					if (<xsl:call-template name="alias_replace">
							<xsl:with-param name="params" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Parameter | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReceivePort"/>		
						<xsl:with-param name="aliases" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias"/>
						<xsl:with-param name="string" select="SMLCL:Trigger/SMLCL:MathInline"/>
				</xsl:call-template>) {
						trans<xsl:value-of name="thisTrans" select="generate-id(.)"/> = true;
					}
</xsl:template>

<xsl:template match="SMLCL:OnCondition" mode="doTrans">
					//OnCondition
					if (trans<xsl:value-of name="thisTrans" select="generate-id(.)"/>) {
					//transition = true;
	<xsl:apply-templates select="SMLCL:StateAssignment | SMLCL:EventOut | SMLCL:ImpulseOut"/>
					<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regimeNext[num]=<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@target_regime"/>;
					}
</xsl:template>

<xsl:include href="SpineML_StateAssignment.xsl"/>
<xsl:include href="SpineML_EventOut.xsl"/>
<xsl:include href="SpineML_ImpulseOut.xsl"/>
<!--xsl:include href="SpineML_Trigger.xsl"/-->

</xsl:stylesheet>
