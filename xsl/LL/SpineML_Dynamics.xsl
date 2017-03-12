<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Dynamics" mode="doEventInputs"> <!-- Used in SpineML_2_BRAHMS_CL_postsyn.xsl -->
			//Dynamics events (doEventInputs)
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
			//Dynamics events (doImpulseInputs)
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
						{
							<xsl:apply-templates select="SMLCL:OnImpulse[@src_port=$port]" mode="doImpulseInputs"/>
							break;
						}
						</xsl:for-each>
					}
				}
			}
			</xsl:for-each>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doEventInputsRemap"> <!-- Used in SpineML_2_BRAHMS_CL_weight.xsl -->
			//Dynamics events (doEventInputsRemap)
			<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:EventReceivePort">
			<xsl:choose>
			<xsl:when test="@post">
			<xsl:variable name="port" select="@name"/>
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
			</xsl:when>
			<xsl:otherwise>
			<xsl:variable name="port" select="@name"/>
			if (delayBuffer.size()) { // Then we want the spikes from the back of the buffer, rather than from the whole buffer. No?
				// I think this wants to be just "for the right index":
				int rightIndex = delayBufferIndex; // or delayBufferIndexBack
				for (int i_BRAHMS = 0; i_BRAHMS &lt; delayBuffer[rightIndex].size(); ++i_BRAHMS) {

					num_BRAHMS = delayBuffer[rightIndex][i_BRAHMS];
					//bout &lt;&lt; "index " &lt;&lt; i_BRAHMS &lt;&lt; " of delayBuffer " &lt;&lt; rightIndex &lt;&lt; D_INFO;
					switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) {
						<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
						//Regime for event at src_port <xsl:value-of select="$port"/>
						case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
						{
							<xsl:apply-templates select="SMLCL:OnEvent[@src_port=$port]" mode="doEventInputs"/>
							break;
						}
						</xsl:for-each>
						default:
						{
							break;
						}
					}
				}
				delayBuffer[rightIndex].clear();

			} else {
				for (int in_BRAHMS = 0; in_BRAHMS &lt; DATA<xsl:value-of select="@name"/>.size(); ++in_BRAHMS) {
					for (int i_BRAHMS = 0; i_BRAHMS &lt; DATA<xsl:value-of select="@name"/>[in_BRAHMS].size(); ++i_BRAHMS) {
						num_BRAHMS = DATA<xsl:value-of select="@name"/>[in_BRAHMS][i_BRAHMS];

						switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) {
							<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Regime">
							//Regime
							case <xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'X__X')"/><xsl:value-of select="@name"/>:
							{
								<xsl:apply-templates select="SMLCL:OnEvent[@src_port=$port]" mode="doEventInputs"/>
								break;
							}
							</xsl:for-each>
							default:
							{
								break;
							}
						}
					}
				}
			}
			</xsl:otherwise>
			</xsl:choose>
			</xsl:for-each> <!-- EventReceivePort -->
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doImpulseInputsRemap">
			//Dynamics events (doImpulseInputsRemap)
			<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:ImpulseReceivePort">
			<xsl:choose>
			<xsl:when test="@post">
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
			</xsl:when>
			<xsl:otherwise>
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
			</xsl:otherwise>
			</xsl:choose>
			</xsl:for-each>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doAllToAllTrans">
<!---->
				//bout &lt;&lt; "doAllToAllTrans..." &lt;&lt; D_INFO;
			<xsl:if test="count(//SMLCL:OnCondition) > 0">
				//Dynamics transitions (doAllToAllTrans)
				for (num_BRAHMS = 0; num_BRAHMS &lt; numEl_BRAHMS; ++num_BRAHMS) {
					// switch on regime:
					switch (<xsl:value-of select="concat(translate(/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', '_H'), 'O__O')"/>regime[num_BRAHMS]) {
					<xsl:apply-templates select="SMLCL:Regime" mode="doTrans"/>
					}
				}
			</xsl:if>
<!---->
			<xsl:if test="count(SMLCL:Alias) > 0">
				<!-- Special-case code to compute the sum of inputs with each bit of Alias maths applied.  -->
				DOUBLE <xsl:value-of select="//SMLCL:AnalogSendPort/@name"/>_SUM = 0;
				for (num_BRAHMS = 0; num_BRAHMS &lt; numEl_BRAHMS; ++num_BRAHMS) {
					<xsl:apply-templates select="SMLCL:Alias[@name=//SMLCL:AnalogSendPort/@name]" mode="doPortAssignmentsAllToAllFixedPreCompute"/>
				}
				<xsl:value-of select="//SMLCL:AnalogSendPort/@name"/>.assign(numEl_BRAHMS, <xsl:value-of select="//SMLCL:AnalogSendPort/@name"/>_SUM);
			</xsl:if>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doTrans">
			<xsl:if test="count(//SMLCL:OnCondition) > 0">
			//Dynamics transitions (doTrans)
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
					<xsl:apply-templates select="SMLCL:Alias[@name=//SMLCL:AnalogSendPort/@name]" mode="doPortAssignments"/>
				<!--/xsl:if-->
			}
			</xsl:if>
</xsl:template>

<xsl:template match="SMLCL:Dynamics" mode="doIter">
			<xsl:if test="count(//SMLCL:TimeDerivative | //SMLCL:Alias) > 0">
			//Dynamics time derivatives (doIter)
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
