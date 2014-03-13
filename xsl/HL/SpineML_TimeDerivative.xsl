<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:TimeDerivative" mode="defineTimeDerivFuncs">
//TimeDerivative
float <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'V__V')"/><xsl:value-of select="@variable"/>(float val, int num) {
float return_val;
<xsl:value-of select="@variable"/>[num] = val;
return_val = <xsl:call-template name="alias_replace">
							<xsl:with-param name="params" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Parameter | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReceivePort"/>
							<xsl:with-param name="aliases" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias"/>
							<xsl:with-param name="string" select="SMLCL:MathInline"/>
							</xsl:call-template>;
return return_val;
}
//float (*  <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/>)(float val, int num);
</xsl:template>

<xsl:template match="SMLCL:TimeDerivative" mode="defineTimeDerivFuncsPtr1">
//TimeDerivative
float (COMPONENT_CLASS_CPP::*  <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/>)(float, int);
</xsl:template>



<xsl:template match="SMLCL:TimeDerivative" mode="defineTimeDerivFuncsPtr">
(<xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/>) = &amp;COMPONENT_CLASS_CPP::<xsl:value-of select="concat(translate(../@name,' -', '_H'), 'V__V')"/><xsl:value-of select="@variable"/>;
</xsl:template>



<xsl:template match="SMLCL:TimeDerivative" mode="doIter">
					//TimeDerivative
					float <xsl:value-of select="@variable"/>_tempVALforINT = this->integrate(float(<xsl:value-of select="@variable"/>[num]), <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/> , num);
</xsl:template>

<xsl:template match="SMLCL:TimeDerivative" mode="assignIterVal">
					//TimeDerivative finalisation
					<xsl:value-of select="@variable"/>[num] = <xsl:value-of select="@variable"/>_tempVALforINT;
</xsl:template>

</xsl:stylesheet>
