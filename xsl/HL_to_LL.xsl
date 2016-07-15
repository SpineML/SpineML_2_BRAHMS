<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:LL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
  version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>

  <!-- Need to add LL: namespace to following elements:
       SpineML,
  <xs:element name="Group" type="GroupType"></xs:element>
  <xs:element name="Input" type="InputType"></xs:element>
  <xs:element name="Neuron" type="NeuronType"></xs:element>
  <xs:element name="WeightUpdate" type="WeightUpdateType"></xs:element>
  <xs:element name="PostSynapse" type="PostSynapseType"></xs:element>
  <xs:element name="Population" type="PopulationType"></xs:element>
  <xs:element name="Projection" type="ProjectionType"></xs:element>
  <xs:element name="Synapse" type="SynapseType"></xs:element>
  <xs:element name="Annotation" type="AnnotationType" ></xs:element>
 -->

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

			<xsl:when test="name() = 'SpineML' and not(@name)">
				<xsl:element name="LL:{name()}" namespace="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer">
					<xsl:copy-of select="namespace::*"/>
					<xsl:attribute name="name">default</xsl:attribute>
					<xsl:apply-templates select="node()|@*"/> <!-- Calls the "copy" template -->
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
