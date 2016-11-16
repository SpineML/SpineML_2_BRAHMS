<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer"
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer"
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- This xsl file generates the SystemML <Process> for a weight
     update. It's called by SpineML_2_BRAHMS_NL.xsl which generates
     the overall SystemML description file sys.xml. -->

<!-- START TEMPLATE -->
<xsl:template name="networkLayerWeightUpdates">

	<!-- Obtain model directory parameter from calling xsl -->
	<xsl:param name="spineml_model_dir" select="'../../model'"/>

	<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
	<xsl:variable name="expt_root" select="/"/>

	<!-- ENTER THE EXPERIMENT FILE -->
	<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

		<!-- GET THE SAMPLE RATE -->
		<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

		<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
		<xsl:variable name="main_root" select="/"/>

		<!-- OLD CODE BELOW - COMMENTING MAY BE SPORADIC -->
		<xsl:for-each select="//SMLLOWNL:Synapse">

			<xsl:variable name="curr_syn" select="SMLLOWNL:WeightUpdate"/>
			<xsl:variable name="target_name" select="../@dst_population"/>
			<xsl:variable name="source_name" select="../../SMLLOWNL:Neuron/@name"/>

			<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

				<xsl:variable name="sizeIn">
					<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
						<xsl:if test="SMLLOWNL:Neuron/@name=$source_name">
							<xsl:value-of select="SMLLOWNL:Neuron/@size"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>

				<xsl:variable name="sizeOut">
					<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
						<xsl:if test="SMLLOWNL:Neuron/@name=$target_name">
							<xsl:value-of select="SMLLOWNL:Neuron/@size"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="linked_file" select="document(SMLLOWNL:WeightUpdate/@url)"/>
				<Process>
					<xsl:comment>Generated by SpineML_WeightUpdate_NL.xsl</xsl:comment>
					<Name><xsl:value-of select="translate(.//SMLLOWNL:WeightUpdate/@name, ' -', '_H')"/></Name>
					<Class>dev/SpineML/temp/WU/<xsl:value-of select="local-name(SMLNL:ConnectionList)"/><xsl:value-of select="local-name(SMLNL:FixedProbabilityConnection)"/><xsl:value-of select="local-name(SMLNL:AllToAllConnection)"/><xsl:value-of select="local-name(SMLNL:OneToOneConnection)"/><xsl:value-of select="translate(document(SMLLOWNL:WeightUpdate/@url)//SMLCL:ComponentClass/@name,' -', 'oH')"/></Class>
					<Time>
						<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
					</Time>
					<State>
						<xsl:variable name="weightupdate_name" select=".//SMLLOWNL:WeightUpdate/@name"/>
						<xsl:attribute name="c">z</xsl:attribute>
						<xsl:attribute name="a">model_directory;sizeIn;sizeOut;<xsl:if test="./SMLNL:ConnectionList/SMLNL:BinaryFile">_bin_file_name;_bin_num_conn;_bin_has_delay;</xsl:if><xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Connection)>0">src;dst;<xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Delay)=0">delayForConn;</xsl:if></xsl:if>
						<!-- If there's a Uniform/Normal Distribution but no experiment layer delay change override, then incude the pDelay -->

						<xsl:if test="count(.//SMLNL:Delay/SMLNL:UniformDistribution)=1 and count($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue)=0">
							<!---->pDelay;<!---->
						</xsl:if>
						<xsl:if test="count(.//SMLNL:Delay/SMLNL:NormalDistribution)=1 and count($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue)=0">
							<!---->pDelay;<!---->
						</xsl:if>
						<xsl:if test="count(.//SMLNL:FixedProbabilityConnection)=1">probabilityValue;</xsl:if>
						<xsl:for-each select="SMLLOWNL:WeightUpdate/SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_syn/@name]/SMLNL:Property">
							<xsl:value-of select="@name"/>
							<xsl:if test="count(.//SMLNL:UniformDistribution)>0 or count(.//SMLNL:NormalDistribution)>0">
								<!---->RANDX<!---->
							</xsl:if>
							<xsl:if test="local-name(..)='Configuration'">
								<!---->OVER2<!---->
							</xsl:if>
							<xsl:if test="count(.//SMLNL:BinaryFile)">
								<!---->BIN_FILE_NAME<!---->
								<!---->;<!---->
								<xsl:value-of select="@name"/>
								<!---->BIN_NUM_ELEMENTS<!---->
							</xsl:if>
							<!---->;<!---->
							<xsl:if test="count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=1 and count(.//SMLNL:ValueList)=1">
								<xsl:value-of select="@name"/>
								<!---->OVER1<!---->
								<!---->;<!---->
							</xsl:if>
						</xsl:for-each>
						<!-- LOGS, WHERE NOT LOGGING 'ALL' -->
						<xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@tcp_port) and @indices and @target=$curr_syn/@name]">
							<xsl:value-of select="concat(@port,'LOG')"/>
							<!---->;<!---->
						</xsl:for-each>
						<!-- LOGS, WHERE LOGGING 'ALL' -->
						<xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@tcp_port) and not(@indices) and @target=$curr_syn/@name]">
							<xsl:value-of select="concat(@port,'LOG')"/>
							<!---->;<!---->
						</xsl:for-each>
						<!-- A FILENAME FOR LOGGING -->
						<!---->logfileNameForComponent;<!---->
						</xsl:attribute>
						<xsl:attribute name="Format">DataML</xsl:attribute>
						<xsl:attribute name="Version">5</xsl:attribute>
						<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
						<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
						<m><xsl:value-of select="$spineml_model_dir"/></m>
						<m c="f"><xsl:value-of select="$sizeIn"/></m>
						<m c="f"><xsl:value-of select="$sizeOut"/></m>
						<!-- Inclusion of the binary connections file name here. -->
						<xsl:if test="./SMLNL:ConnectionList/SMLNL:BinaryFile">
							<!-- Find (within the Synapse which contains the weight update) <ConnectionList> in the model.xml file -->
							<m><xsl:value-of select="./SMLNL:ConnectionList/SMLNL:BinaryFile/@file_name"/></m>
							<m c="f"><xsl:value-of select="./SMLNL:ConnectionList/SMLNL:BinaryFile/@num_connections"/></m>
							<m c="f"><xsl:value-of select="./SMLNL:ConnectionList/SMLNL:BinaryFile/@explicit_delay_flag"/></m>
						</xsl:if>
						<xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Connection)>0">
							<m>
								<xsl:attribute name="b">1 <xsl:value-of select="count(./SMLNL:ConnectionList/SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
								<xsl:for-each select="./SMLNL:ConnectionList/SMLNL:Connection"><xsl:value-of select="@src_neuron"/><xsl:text> </xsl:text></xsl:for-each>
							</m>
							<m><xsl:attribute name="b">1 <xsl:value-of select="count(./SMLNL:ConnectionList/SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
							<xsl:for-each select="./SMLNL:ConnectionList/SMLNL:Connection"><xsl:value-of select="@dst_neuron"/><xsl:text> </xsl:text></xsl:for-each>
							</m>
							<xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Delay)=0">
								<m><xsl:attribute name="b">1 <xsl:value-of select="count(./SMLNL:ConnectionList/SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
								<xsl:for-each select="./SMLNL:ConnectionList/SMLNL:Connection"><xsl:value-of select="@delay"/><xsl:text> </xsl:text></xsl:for-each>
								</m>
							</xsl:if>
						</xsl:if>
						<xsl:if test="count(.//SMLNL:Delay/SMLNL:UniformDistribution)=1 and count($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue)=0">
							<m b="1 4" c="f">
								<!---->2 <!---->
								<xsl:value-of select=".//SMLNL:Delay/SMLNL:UniformDistribution/@minimum"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select=".//SMLNL:Delay/SMLNL:UniformDistribution/@maximum"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select=".//SMLNL:Delay/SMLNL:UniformDistribution/@seed"/>
							</m>
						</xsl:if>
						<xsl:if test="count(.//SMLNL:Delay/SMLNL:NormalDistribution)=1 and count($expt_root//SMLEXPT:Delay[@weight_update=$weightupdate_name]/SMLNL:FixedValue)=0">
							<m b="1 4" c="f">
								<!---->1 <!---->
								<xsl:value-of select=".//SMLNL:Delay/SMLNL:NormalDistribution/@mean"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select=".//SMLNL:Delay/SMLNL:NormalDistribution/@variance"/>
								<xsl:text> </xsl:text>
								<xsl:value-of select=".//SMLNL:Delay/SMLNL:NormalDistribution/@seed"/>
							</m>
						</xsl:if>
						<xsl:if test="count(./SMLNL:FixedProbabilityConnection)=1"><m c="f"><xsl:value-of select=".//SMLNL:FixedProbabilityConnection/@probability"/></m></xsl:if>
						<xsl:for-each select="SMLLOWNL:WeightUpdate//SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_syn/@name]/SMLNL:Property">

							<!-- NO VALUE -->
							<xsl:if test="count(.//*)=0">
								<m c="f">
									<xsl:value-of select="'0'"/>
								</m>
							</xsl:if>
							<!-- FIXED VALUE -->
							<xsl:if test="count(.//SMLNL:FixedValue)>0">
								<m c="f">
									<xsl:value-of select=".//SMLNL:FixedValue/@value"/>
								</m>
							</xsl:if>
							<!-- STOCHASTIC VALUE (NORMAL) -->
							<xsl:if test="count(.//SMLNL:NormalDistribution)>0">
								<m b="1 4" c="f">
									<!---->1 <!---->
									<xsl:value-of select=".//SMLNL:NormalDistribution/@mean"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select=".//SMLNL:NormalDistribution/@variance"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select=".//SMLNL:NormalDistribution/@seed"/>
								</m>
							</xsl:if>
							<!-- STOCHASTIC VALUE (UNIFORM) -->
							<xsl:if test="count(.//SMLNL:UniformDistribution)>0">
								<m b="1 4" c="f">
									<!---->2 <!---->
									<xsl:value-of select=".//SMLNL:UniformDistribution/@minimum"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select=".//SMLNL:UniformDistribution/@maximum"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select=".//SMLNL:UniformDistribution/@seed"/>
								</m>
							</xsl:if>
							<!-- VALUE LIST -->
							<xsl:if test="count(.//SMLNL:ValueList)=1 and count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=0">
								<xsl:choose>
									<xsl:when test="count(.//SMLNL:ValueList/SMLNL:BinaryFile)">
										<m><xsl:value-of select=".//SMLNL:ValueList/SMLNL:BinaryFile/@file_name"/></m>
										<m c="f"><xsl:value-of select=".//SMLNL:ValueList/SMLNL:BinaryFile/@num_elements"/></m>
									</xsl:when>
									<xsl:otherwise>
										<m><xsl:attribute name="b">
											<!-- These cases act on the experiment file, which you can tell from local-name and the Configuration element -->
											<xsl:if test="local-name(..)='Configuration' and count(.//SMLNL:Value) &lt; number($sizeIn) and not(count(.//@index)=count(.//SMLNL:Value))">
												<xsl:message terminate="yes">
													Error - incomplete value list without indices in experimental override for population <xsl:value-of select="$curr_pop/SMLLOWNL:Neuron/@name"/>, property <xsl:value-of select="@name"/>.
												</xsl:message>
											</xsl:if>
											<xsl:choose>
												<xsl:when test="local-name(..)='Configuration' and count(.//SMLNL:Value) &lt; number($sizeIn)">
													<!---->2 <!---->
												</xsl:when>
												<xsl:otherwise>
													<!---->1 <!---->
												</xsl:otherwise>
											</xsl:choose>
											<xsl:value-of select="count(.//SMLNL:Value)"/>
										</xsl:attribute>
										<xsl:attribute name="c">
											<!---->f<!---->
										</xsl:attribute>
										<xsl:for-each select=".//SMLNL:Value">
											<xsl:if test="local-name(../../..)='Configuration' and count(../SMLNL:Value) &lt; number($sizeIn)">
												<xsl:value-of select="@index"/>
												<xsl:text> </xsl:text>
											</xsl:if>
											<xsl:value-of select="@value"/>
											<xsl:text> </xsl:text>
										</xsl:for-each>
										</m>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>

						</xsl:for-each>
						<!-- LOGS, WHERE NOT LOGGING 'ALL' -->
						<xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@tcp_port) and @indices and @target=$curr_syn/@name]">
							<m><xsl:attribute name="b">1 <!---->
							<xsl:call-template name="count_array_items">
								<xsl:with-param name="items" select="@indices"/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:attribute name="c">f</xsl:attribute>
						<xsl:value-of select="translate(@indices,',',' ')"/>
							</m>
						</xsl:for-each>
						<xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@tcp_port) and not(@indices) and @target=$curr_syn/@name]">
							<m><xsl:attribute name="b">1 1<!---->
						</xsl:attribute>
						<xsl:attribute name="c">f</xsl:attribute>
						<!---->-1<!---->
							</m>
						</xsl:for-each>
						<!-- NAME FOR USE IN LOGS -->
						<m><xsl:value-of select="translate(SMLLOWNL:WeightUpdate/@name,' ', '_')"/></m>
					</State>
				</Process>

			</xsl:if>

		</xsl:for-each>

		<!-- EXIT THE EXPERIMENT FILE -->
	</xsl:for-each>

	<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
