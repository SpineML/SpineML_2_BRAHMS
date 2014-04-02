<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>
<!--

Ok, here we attempt to get a network layer description into giving us a systemML description...

-->

<xsl:param name="spineml_2_brahms_dir" select="'../../'"/>

<xsl:template name="count_array_items">
<xsl:param name="items"/>
<xsl:param name="count" select="1"/>
<xsl:choose>
<xsl:when test="contains($items, ',')">
<xsl:variable name="item" select="substring-before($items,',')"/>
<xsl:variable name="remaining_items" select="substring-after($items,',')"/>
<xsl:call-template name="count_array_items">
	<xsl:with-param name="items" select="$remaining_items"/>
	<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$count"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="/">

<!-- WRITE THE OPENING TAG -->
<System Version="1.0" AuthTool="SpineML to BRAHMS XSLT translator" AuthToolVersion="0">


<!-- ###################### COMPONENTS ########################### -->

<!-- SEE FILE SpineML_Neuron_NL.xml -->
<xsl:call-template name="networkLayerNeurons"/>

<!-- SEE FILE SpineML_WeightUpdate_NL.xml -->
<xsl:call-template name="networkLayerWeightUpdates"/>

<!-- SEE FILE SpineML_PostSynapse_NL.xml -->
<xsl:call-template name="networkLayerPostSynapses"/>


<!-- ######################### LINKS ############################## -->

<!-- SEE FILE SpineML_GenericInput_NL.xml -->
<xsl:call-template name="networkLayerProjectionLinks"/>


<!-- ###################### GENENIC INPUTS ######################## -->

<!-- SEE FILE SpineML_GenericInput_NL.xml -->
<xsl:call-template name="networkLayerGenericInputs">
	<xsl:with-param name="spineml_2_brahms_dir" select="$spineml_2_brahms_dir"/>
</xsl:call-template>


<!-- ###################### SOURCE INPUTS ######################### -->

<!-- SEE FILE SpineML_ConstantInput_NL.xml -->
<xsl:call-template name="networkLayerConstantInputs"/>

<!-- SEE FILE SpineML_ArrayConstantInput_NL.xml -->
<xsl:call-template name="networkLayerArrayConstantInputs"/>

<!-- SEE FILE SpineML_TimeVaryingInput_NL.xml -->
<xsl:call-template name="networkLayerTimeVaryingInputs"/>

<!-- SEE FILE SpineML_ArrayTimeVaryingInput_NL.xml -->
<xsl:call-template name="networkLayerArrayTimeVaryingInputs"/>

<!-- SEE FILE SpineML_ExternalInput_NL.xml -->
<xsl:call-template name="networkLayerExternalInputs"/>

<!-- ###################### EXTERNAL OUTPUTS ####################### -->

<!-- SEE FILE SpineML_ExternalOutput_NL.xml -->
<xsl:call-template name="networkLayerExternalOutputs"/>

<!-- WRITE THE CLOSING TAG -->
</System>


</xsl:template>

<xsl:include href="SpineML_Neuron_NL.xsl"/>
<xsl:include href="SpineML_WeightUpdate_NL.xsl"/>
<xsl:include href="SpineML_PostSynapse_NL.xsl"/>
<xsl:include href="SpineML_GenericInput_NL.xsl"/>
<xsl:include href="SpineML_ConstantInput_NL.xsl"/>
<xsl:include href="SpineML_ArrayConstantInput_NL.xsl"/>
<xsl:include href="SpineML_TimeVaryingInput_NL.xsl"/>
<xsl:include href="SpineML_ArrayTimeVaryingInput_NL.xsl"/>
<xsl:include href="SpineML_ExternalInput_NL.xsl"/>
<xsl:include href="SpineML_ProjectionLinks_NL.xsl"/>
<xsl:include href="SpineML_ExternalOutput_NL.xsl"/>

</xsl:stylesheet>


