<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
		xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
		xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer"
		xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer"
		xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
	<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

	<!-- This xsl file provides a template which generates the SystemML
	     <Link> entries, which describe how the different components (the
	     <Processes>) are connected together. Note this does not make
	     links when the link is a GenericInput. These are made in
	     SpineML_GenericInput_NL.xsl. -->

	<!-- START TEMPLATE -->
	<xsl:template name="networkLayerProjectionLinks">

		<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
		<xsl:variable name="expt_root" select="/"/>

		<!-- ENTER THE EXPERIMENT FILE -->
		<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

			<!-- GET THE SAMPLE RATE -->
			<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

			<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
			<xsl:variable name="main_root" select="/"/>

			<!-- OLD CODE BELOW - COMMENTING MAY BE SPORADIC -->

			<!-- ############### SOURCE NEURON TO WEIGHT UPDATE ############### -->
			<xsl:for-each select="//SMLLOWNL:WeightUpdate">

				<xsl:variable name="target_name" select="../../@dst_population"/>
				<xsl:variable name="source_name" select="../../../SMLLOWNL:Neuron/@name"/>
				<xsl:variable name="weightupdate_name" select="./@name"/>

				<!-- APPLY LESION -->
				<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0"><!-- if no lesion, then fill it in: -->

					<xsl:if test="not(../../../SMLLOWNL:Neuron/@url='SpikeSource')">

						<xsl:variable name="dstPortRef" select="@input_dst_port"/>
						<Link>
							<Src><xsl:value-of select="translate(../../../SMLLOWNL:Neuron/@name,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@input_src_port"/></Src>

							<Dst><xsl:value-of select="translate(@name,' -', '_H')"/><xsl:if test="count(document(@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@input_dst_port"/></Dst>

							<Lag>

								<!-- To trigger expt-provided delay, have something like this in the experiment file:
								<Model network_layer_url="model.xml">
									<Delay weight_update="PopA_to_PopB_Synapse_0_weight_update" dimension="ms">
										<UL:FixedValue value="23"/>
									</Delay>
								</Model> -->
								<xsl:choose>
									<xsl:when test="count(../*/SMLNL:Delay/SMLNL:FixedValue)=1 or (count($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue)=1 and count(../SMLNL:ConnectionList)=0)">
										<xsl:if test="count($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue)=1">
											<xsl:comment>Expt layer value: </xsl:comment>
											<xsl:value-of select="number($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue/@value) div $expt_root//@dt"/>
										</xsl:if>
										<xsl:if test="count(../*/SMLNL:Delay/SMLNL:FixedValue)=1 and count($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue)=0">
											<xsl:comment>Model-provided delay: </xsl:comment>
											<xsl:value-of select="number(../*/SMLNL:Delay/SMLNL:FixedValue/@value) div $expt_root//@dt"/>
										</xsl:if>
									</xsl:when>

									<xsl:when test="count(../SMLNL:ConnectionList)=1"><xsl:comment>One timestep added to tell BRAHMS that there IS a delay in the ConnectionList</xsl:comment>1</xsl:when>

									<!-- If the Delay is e.g. UniformDistribution or NormalDistribution, then it's handled in the
									     weight update component, with parameters passed in by SpineML_WeightUpdate_NL.xsl hence the "otherwise 0" here: -->
									<xsl:otherwise>0</xsl:otherwise>
								</xsl:choose>
							</Lag>

						</Link>

					</xsl:if>
				</xsl:if>

			</xsl:for-each>

			<!-- ############### WEIGHT UPDATE TO POSTSYNAPSE ############### -->
			<xsl:for-each select="//SMLLOWNL:PostSynapse">

				<xsl:variable name="target_name" select="../../@dst_population"/>
				<xsl:variable name="source_name" select="../../../SMLLOWNL:Neuron/@name"/>

				<!-- APPLY LESION -->
				<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

					<xsl:variable name="dstPortRef" select="@input_dst_port"/>
					<Link>
						<Src><xsl:value-of select="translate(../SMLLOWNL:WeightUpdate/@name,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@input_src_port"/></Src>
						<Dst><xsl:value-of select="translate(@name,' -', '_H')"/><xsl:if test="count(document(@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@input_dst_port"/></Dst>
						<Lag>0</Lag>
					</Link>

				</xsl:if>

			</xsl:for-each>

			<!-- ############### POSTSYNAPSE TO DEST NEURON ############### -->
			<xsl:for-each select="//SMLLOWNL:PostSynapse">

				<xsl:variable name="target_name" select="../../@dst_population"/>
				<xsl:variable name="source_name" select="../../../SMLLOWNL:Neuron/@name"/>

				<!-- APPLY LESION -->
				<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

					<xsl:variable name="dstPortRef" select="@output_dst_port"/>
					<xsl:variable name="dstPopRef" select="../../@dst_population"/>
					<Link>
						<Src><xsl:value-of select="translate(@name,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@output_src_port"/></Src>
						<Dst><xsl:value-of select="translate(../../@dst_population,' -', '_H')"/><xsl:if test="count(document(//SMLLOWNL:Population[SMLLOWNL:Neuron/@name=$dstPopRef]/SMLLOWNL:Neuron/@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(//SMLLOWNL:Population[SMLLOWNL:Neuron/@name=$dstPopRef]/SMLLOWNL:Neuron/@url)//SMLCL:EventReceivePort[@name=$dstPortRef]) or count(document(//SMLLOWNL:Population[SMLLOWNL:Neuron/@name=$dstPopRef]/SMLLOWNL:Neuron/@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@output_dst_port"/></Dst>
						<Lag>0</Lag>
					</Link>

				</xsl:if>

			</xsl:for-each>



			<!-- EXIT THE EXPERIMENT FILE -->
		</xsl:for-each>

		<!-- END TEMPLATE -->
	</xsl:template>

</xsl:stylesheet>
