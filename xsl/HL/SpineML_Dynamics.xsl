<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Dynamics" mode="doEventInputs">
			//Dynamics events
			<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort">
			<xsl:variable name="port" select="@name"/>
			for (int in = 0; in &lt; DATA<xsl:value-of select="@name"/>.size(); ++in) {
				for (int i = 0; i &lt; COUNT<xsl:value-of select="@name"/>[in]; ++i) {
				num = DATA<xsl:value-of select="@name"/>[in][i];

					switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
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
			for (int in = 0; in &lt; DATA<xsl:value-of select="@name"/>.size(); ++in) {
				for (int i = 0; i &lt; COUNT<xsl:value-of select="@name"/>[in]; i+=3) {
				// extract impulse
				INT32 impulseIndex__In;
				DOUBLE impulseValue__In;
				getImpulse(DATA<xsl:value-of select="@name"/>[in], i, impulseIndex__In, impulseValue__In);
				num = impulseIndex__In;
				// assign the impulse value
				<xsl:value-of select="@name"/>[num] = impulseValue__In;

					switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
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
				for (int i =0; i &lt; delayBuffer[delayBufferIndex].size();++i) {
					num = delayBuffer[delayBufferIndex][i];
						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
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
				for (int in = 0; in &lt; DATA<xsl:value-of select="@name"/>.size(); ++in) {
					for (int i = 0; i &lt; DATA<xsl:value-of select="@name"/>[in].size(); ++i) {
					num = DATA<xsl:value-of select="@name"/>[in][i];

						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
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
				for (int i =0; i &lt; delayBuffer[delayBufferIndex].size();++i) {
					num = delayBuffer[delayBufferIndex][i];
					<xsl:value-of select="@name"/>[num] = delayedImpulseValue[delayBufferIndex][i];
						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
							<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
							//Regime
							case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
								<xsl:apply-templates select="SMLCL:OnImpulse[@src_port=$port]" mode="doImpulseInputs"/>
							break;
							</xsl:for-each>
						}
				}
				delayBuffer[delayBufferIndex].clear();
				delayedImpulseValue[delayBufferIndex].clear();
			} else {
				for (int in = 0; in &lt; DATA<xsl:value-of select="@name"/>.size(); ++in) {
					for (int i = 0; i &lt; DATA<xsl:value-of select="@name"/>[in].size(); i+=3) {
					// extract impulse
					INT32 impulseIndex__In;
					DOUBLE impulseValue__In;
					getImpulse(DATA<xsl:value-of select="@name"/>[in], i, impulseIndex__In, impulseValue__In);
					num = impulseIndex__In;
					// assign the impulse value
					<xsl:value-of select="@name"/>[num] = impulseValue__In;

						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
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
			for (num = 0; num &lt; numEl; ++num) {


				// switch on regime:
				switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
	<xsl:apply-templates select="SMLCL:Regime" mode="doTrans"/>
				}
			}
			</xsl:if>
			<xsl:if test="count(SMLCL:Alias) > 0">
			for (num = 0; num &lt; numEl; ++num) {
<!---->			<!-- Only do this here if we are not an event driven component -->
				<xsl:if test="count(//SMLCL:TimeDerivative | SMLCL:AnalogReceivePort | SMLCL:AnalogReducePort) > 0">
					<xsl:apply-templates select="SMLCL:Alias" mode="doPortAssignments"/>
				</xsl:if>
			}
			</xsl:if>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doIter">
			<xsl:if test="count(//SMLCL:TimeDerivative | //SMLCL:Alias) > 0">
			//Dynamics time derivatives
			for (num = 0; num &lt; numEl; ++num) {

				// switch on regime:
				switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num]) { 
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
