<?xml version="1.0" encoding="UTF-8"?>
<!--
This is an XSLT transformation to convert a high level SpineML
model into a low level representation, so that the model can be
executed by SpineML_2_BRAHMS.

It will add the "LL:" namespace to the following elements: SpineML,
Group, Input, Neuron, WeighUpdate, PostSynapse, Population,
Projection, Synapse, Annotation.

Additionally, it ensures that the SpineML element contains a name
attribute, which is required by the low level SpineML specification.

Seb James, July 2016
-->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:LL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
    version="1.0">

 <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

 <!-- This is the "copy" template -->
 <xsl:template match="node()|@*">
  <xsl:copy>
   <xsl:apply-templates select="node()|@*"/>
  </xsl:copy>
 </xsl:template>

 <!-- This template is applied first -->
 <xsl:template match="*">

  <xsl:choose>

   <!-- If the node name is in the list of lowlevel elements, then
	convert them here. -->
   <xsl:when test="(name() = 'SpineML' and @name) or name() = 'Group' or name() =
		   'Input' or name() = 'Neuron' or name() =
		   'WeightUpdate' or name() = 'PostSynapse' or name()
		   = 'Population' or name() = 'Projection' or name() =
		   'Synapse' or name() = 'Annotation'">
    <xsl:element name="LL:{name()}" namespace="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer">
     <xsl:copy-of select="namespace::*"/>
     <xsl:apply-templates select="node()|@*"/> <!-- Calls the "copy" template -->
    </xsl:element>
   </xsl:when>

   <!-- Special case for SpineML element to ensure it gets a name attribute -->
   <xsl:when test="name() = 'SpineML' and not(@name)">
    <xsl:element name="LL:{name()}" namespace="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer">
     <xsl:copy-of select="namespace::*"/>
     <xsl:attribute name="name">Converted from high level</xsl:attribute>
     <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
   </xsl:when>

   <!-- Other nodes remain in the high level namespace -->
   <xsl:otherwise>
    <xsl:element name="{name()}" namespace="http://www.shef.ac.uk/SpineMLNetworkLayer">
     <xsl:copy-of select="namespace::*"/>
     <xsl:apply-templates select="node()|@*"/>
    </xsl:element>
   </xsl:otherwise>

  </xsl:choose>

 </xsl:template>

</xsl:stylesheet>
