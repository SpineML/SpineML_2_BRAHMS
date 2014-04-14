<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Dynamics" mode="doEventInputs">
			//Dynamics events
			<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort">
			<xsl:variable name="port" select="@name"/>
			for (int in_BRAHMS = 0; in_BRAHMS &lt; DATA<xsl:value-of select="@name"/>.size(); ++in_BRAHMS) {
				for (int i_BRAHMS = 0; i_BRAHMS &lt; COUNT<xsl:value-of select="@name"/>[in_BRAHMS]; ++i_BRAHMS) {
				num_BRAHMS = DATA<xsl:value-of select="@name"/>[in_BRAHMS][i_BRAHMS];

					switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
						<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
						//Regime
						case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
							<xsl:apply-templates select="SMLCL:OnEvent[@src_port=$port]" mode="doEventInputs"/>
						break;
						</xsl:for-each>
					}
				}
			}
			</xsl:for-each>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doImpulseInputs">
			//Dynamics events
			<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">
			<xsl:variable name="port" select="@name"/>
			for (int in_BRAHMS = 0; in_BRAHMS &lt; DATA<xsl:value-of select="@name"/>.size(); ++in_BRAHMS) {
				for (int i_BRAHMS = 0; i_BRAHMS &lt; COUNT<xsl:value-of select="@name"/>[in_BRAHMS]; i_BRAHMS+=3) {
				// extract impulse
				INT32 impulseIndex__In;
				DOUBLE impulseValue__In;
				getImpulse(DATA<xsl:value-of select="@name"/>[in_BRAHMS], i_BRAHMS, impulseIndex__In, impulseValue__In);
				num_BRAHMS = impulseIndex__In;
				// assign the impulse value
				<xsl:value-of select="@name"/>[num_BRAHMS] = impulseValue__In;

					switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
						<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
						//Regime
						case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
							<xsl:apply-templates select="SMLCL:OnImpulse[@src_port=$port]" mode="doImpulseInputs"/>
						break;
						</xsl:for-each>
					}
				}
			}
			</xsl:for-each>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doEventInputsRemap">
			//Dynamics events
			<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort">
			<xsl:variable name="port" select="@name"/>
			if (delayBuffer.size()) {
				for (int i_BRAHMS =0; i_BRAHMS &lt; delayBuffer[delayBufferIndex].size();++i_BRAHMS) {
					num_BRAHMS = delayBuffer[delayBufferIndex][i_BRAHMS];
						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
							<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
							//Regime
							case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
								<xsl:apply-templates select="SMLCL:OnEvent[@src_port=$port]" mode="doEventInputs"/>
							break;
							</xsl:for-each>
						}
				}
				delayBuffer[delayBufferIndex].clear();
			} else {
				for (int in_BRAHMS = 0; in_BRAHMS &lt; DATA<xsl:value-of select="@name"/>.size(); ++in_BRAHMS) {
					for (int i_BRAHMS = 0; i_BRAHMS &lt; DATA<xsl:value-of select="@name"/>[in_BRAHMS].size(); ++i_BRAHMS) {
					num_BRAHMS = DATA<xsl:value-of select="@name"/>[in_BRAHMS][i_BRAHMS];

						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
							<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
							//Regime
							case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
								<xsl:apply-templates select="SMLCL:OnEvent[@src_port=$port]" mode="doEventInputs"/>
							break;
							</xsl:for-each>
						}
					}
				}
			}
			</xsl:for-each>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doImpulseInputsRemap">
			//Dynamics events
			<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">
			<xsl:variable name="port" select="@name"/>
			if (delayBuffer.size()) {
				for (int i_BRAHMS=0; i_BRAHMS &lt; delayBuffer[delayBufferIndex].size();++i_BRAHMS) {
					num_BRAHMS = delayBuffer[delayBufferIndex][i_BRAHMS];
					<xsl:value-of select="@name"/>[num_BRAHMS] = delayedImpulseVals[delayBufferIndex][i_BRAHMS];
						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
							<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
							//Regime
							case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
								<xsl:apply-templates select="SMLCL:OnImpulse[@src_port=$port]" mode="doImpulseInputs"/>
							break;
							</xsl:for-each>
						}
				}
				delayBuffer[delayBufferIndex].clear();
				delayedImpulseVals[delayBufferIndex].clear();
			} else {
				for (int in_BRAHMS = 0; in_BRAHMS &lt; DATA<xsl:value-of select="@name"/>.size(); ++in_BRAHMS) {
					for (int i_BRAHMS = 0; i_BRAHMS &lt; DATA<xsl:value-of select="@name"/>[in_BRAHMS].size(); i_BRAHMS+=3) {
					// extract impulse
					INT32 impulseIndex__In;
					DOUBLE impulseValue__In;
					getImpulse((INT32 *) &amp;(DATA<xsl:value-of select="@name"/>[in_BRAHMS]), i_BRAHMS, impulseIndex__In, impulseValue__In);
					num_BRAHMS = impulseIndex__In;
					// assign the impulse value
					<xsl:value-of select="@name"/>[num_BRAHMS] = impulseValue__In;

						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
							<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
							//Regime
							case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
								<xsl:apply-templates select="SMLCL:OnImpulse[@src_port=$port]" mode="doImpulseInputs"/>
							break;
							</xsl:for-each>
						}
					}
				}
			}
			</xsl:for-each>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doTrans">
			<xsl:if test="count(//SMLCL:OnCondition) > 0">
			//Dynamics transitions
			for (num_BRAHMS = 0; num_BRAHMS &lt; numEl_BRAHMS; ++num_BRAHMS) {


				// switch on regime:
				switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
	<xsl:apply-templates select="SMLCL:Regime" mode="doTrans"/>
				}
			}
			</xsl:if>
			<xsl:if test="count(SMLCL:Alias) > 0">
			for (num_BRAHMS = 0; num_BRAHMS &lt; numEl_BRAHMS; ++num_BRAHMS) {
<!---->			<!-- Only do this here if we are not an event driven component -->
				<!--xsl:if test="count(//SMLCL:TimeDerivative | SMLCL:AnalogReceivePort | SMLCL:AnalogReducePort) > 0"-->
					<xsl:apply-templates select="SMLCL:Alias" mode="doPortAssignments"/>
				<!--/xsl:if-->
			}
			</xsl:if>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doIter">
			<xsl:if test="count(//SMLCL:TimeDerivative | //SMLCL:Alias) > 0">
			//Dynamics time derivatives
			for (num_BRAHMS = 0; num_BRAHMS &lt; numEl_BRAHMS; ++num_BRAHMS) {

				// switch on regime:
				switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) { 
	<xsl:apply-templates select="SMLCL:Regime" mode="doIter"/>
				}
			}
			</xsl:if>
</xsl:template>

<xsl:include href="SpineML_Regime.xsl"/>
<xsl:include href="SpineML_OnEvent.xsl"/>
<xsl:include href="SpineML_OnImpulse.xsl"/>

<!--xsl:include href="SpineML_StateVariable.xsl"/-->

</xsl:stylesheet>
