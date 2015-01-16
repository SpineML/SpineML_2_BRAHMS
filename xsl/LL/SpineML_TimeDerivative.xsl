<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:TimeDerivative" mode="defineTimeDerivFuncs">
//TimeDerivative
float <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'V__V')"/><xsl:value-of select="@variable"/>(float val_BRAHMS, int num_BRAHMS) {
float return_val_BRAHMS;
<xsl:value-of select="@variable"/>[num_BRAHMS] = val_BRAHMS;
return_val_BRAHMS = <xsl:call-template name="alias_replace">
							<xsl:with-param name="params" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Parameter | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReceivePort"/>
							<xsl:with-param name="aliases" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias"/>
							<xsl:with-param name="string" select="SMLCL:MathInline"/>
							</xsl:call-template>;
return return_val_BRAHMS;
}
float <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'FV__FV')"/><xsl:value-of select="@variable"/>(float val_BRAHMS, int num_BRAHMS) {
float return_val_BRAHMS;
<xsl:value-of select="@variable"/>[num_BRAHMS] = val_BRAHMS;
return_val_BRAHMS = <xsl:call-template name="alias_replace_2">
							<xsl:with-param name="params" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Parameter | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:StateVariable | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReducePort | /SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:AnalogReceivePort"/>
							<xsl:with-param name="aliases" select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias"/>
							<xsl:with-param name="string" select="SMLCL:MathInline"/>
							</xsl:call-template>;
return return_val_BRAHMS;
}
//float (*  <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/>)(float val_BRAHMS, int num_BRAHMS);
</xsl:template>

<xsl:template match="SMLCL:TimeDerivative" mode="defineTimeDerivFuncsPtr1">
//TimeDerivative
float (COMPONENT_CLASS_CPP::*  <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/>)(float, int);
</xsl:template>



<xsl:template match="SMLCL:TimeDerivative" mode="defineTimeDerivFuncsPtr">
					if (all_pars_are_FV) {
					(<xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/>) = &amp;COMPONENT_CLASS_CPP::<xsl:value-of select="concat(translate(../@name,' -', '_H'), 'FV__FV')"/><xsl:value-of select="@variable"/>;
					} else {
					(<xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/>) = &amp;COMPONENT_CLASS_CPP::<xsl:value-of select="concat(translate(../@name,' -', '_H'), 'V__V')"/><xsl:value-of select="@variable"/>;
					}
</xsl:template>



<xsl:template match="SMLCL:TimeDerivative" mode="doIter">
					//TimeDerivative
					float <xsl:value-of select="@variable"/>_tempVALforINT = this->integrate(float(<xsl:value-of select="@variable"/>[num_BRAHMS]), <xsl:value-of select="concat(translate(../@name,' -', '_H'), 'P__P')"/><xsl:value-of select="@variable"/> , num_BRAHMS);
</xsl:template>

<xsl:template match="SMLCL:TimeDerivative" mode="assignIterVal">
					//TimeDerivative finalisation
					<xsl:value-of select="@variable"/>[num_BRAHMS] = <xsl:value-of select="@variable"/>_tempVALforINT;
</xsl:template>

</xsl:stylesheet>
