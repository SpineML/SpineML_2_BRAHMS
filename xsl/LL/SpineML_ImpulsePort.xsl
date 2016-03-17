<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="defineImpulsePorts">
vector &lt; spikes::Input &gt; PORT<xsl:value-of select="@name"/>;
vector &lt; DOUBLE &gt; <xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="defineImpulsePorts">
spikes::Output PORTOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="resizeReceive">
<xsl:text>		</xsl:text><xsl:value-of select="@name"/>.resize(numEl_BRAHMS,0);
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPorts">
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numElements_BRAHMS*60);
</xsl:template>


<xsl:template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPortsWU">
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numConn_BRAHMS*60);
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="createImpulseRecvPorts">
				set_BRAHMS = iif.getSet("<xsl:value-of select="@name"/>");
				numInputs_BRAHMS = iif.getNumberOfPorts(set_BRAHMS);
				PORT<xsl:value-of select="@name"/>.resize(numInputs_BRAHMS);
				for (int i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; numInputs_BRAHMS; ++i_BRAHMS_LOOP) {
					PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].selectSet(set_BRAHMS);
					PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].attach(hComponent, i_BRAHMS_LOOP);

				}

</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePorts">
			vector &lt; INT32* &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS] = PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent(DATA<xsl:value-of select="@name"/>[i_BRAHMS]);
			}
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="serviceImpulsePorts">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; INT32 &gt; DATAOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePortsRemap">

			<xsl:choose>
			<xsl:when test="@post">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; INT32 &gt; &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; DOUBLE &gt; &gt; DATAval<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS_LOOP) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP] = PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].getContent(TEMP<xsl:value-of select="@name"/>);
				// service Impulses port
				for (int j_BRAHMS_LOOP = 0; j_BRAHMS_LOOP &lt; COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP]; j_BRAHMS_LOOP+=3 /* one int + one double = 3 int */) {
					// extract the values
					INT32 impulseIndex__In;
					DOUBLE impulseValue__In;
					getImpulse(TEMP<xsl:value-of select="@name"/>, j_BRAHMS_LOOP, impulseIndex__In, impulseValue__In);
					// remap the input
					for (int k_BRAHMS_LOOP = 0; k_BRAHMS_LOOP &lt; connectivityD2C[impulseIndex__In].size(); ++k_BRAHMS_LOOP) {
						// add the index from the lookup
						DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(connectivityD2C[impulseIndex__In][k_BRAHMS_LOOP]);
						// add the value
						DATAval<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(impulseValue__In);
					}
				}
			}
			</xsl:when>
			<xsl:otherwise>
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; INT32 &gt; &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; DOUBLE &gt; &gt; DATAval<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS_LOOP) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP] = PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].getContent(TEMP<xsl:value-of select="@name"/>);
				// service Impulses port
				for (int j_BRAHMS_LOOP = 0; j_BRAHMS_LOOP &lt; COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP]; j_BRAHMS_LOOP+=3 /* one int + one double = 3 int */) {
					// extract the values
					INT32 impulseIndex__In;
					DOUBLE impulseValue__In;
					getImpulse(TEMP<xsl:value-of select="@name"/>, j_BRAHMS_LOOP, impulseIndex__In, impulseValue__In);
					// remap the input
					for (int k_BRAHMS_LOOP = 0; k_BRAHMS_LOOP &lt; connectivityS2C[impulseIndex__In].size(); ++k_BRAHMS_LOOP) {
						// add the index from the lookup
						DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(connectivityS2C[impulseIndex__In][k_BRAHMS_LOOP]);
						// add the value
						DATAval<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(impulseValue__In);
					}
				}
			}

			// do delay
			if (delayBuffer.size()) {
				// for each spike
				for (UINT32 i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; DATA<xsl:value-of select="@name"/>.size(); ++i_BRAHMS_LOOP) {
					for (UINT32 j_BRAHMS_LOOP = 0; j_BRAHMS_LOOP &lt; DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].size(); ++j_BRAHMS_LOOP) {

						// get delay buffer index to set and add impulse to buffer lists
						delayBuffer[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]])%delayBuffer.size()].push_back(DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]);
						delayedImpulseVals[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]])%delayBuffer.size()].push_back(DATAval<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]);

					}
				}
			}
			</xsl:otherwise>
			</xsl:choose>
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="serviceImpulsePortsRemap">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; INT32 &gt; DATAOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="outputImpulsePorts">
			PORTOut<xsl:value-of select="@name"/>.setContent(&amp;DATAOut<xsl:value-of select="@name"/>[0], DATAOut<xsl:value-of select="@name"/>.size());
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="outputImpulsePortsRemap">

			vector &lt; INT32 &gt; OUT<xsl:value-of select="@name"/>;
			// FIXME FIXME This may break/needs changing for AllToAll optimization!!
			for (INT32 i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; DATAOut<xsl:value-of select="@name"/>.size(); i_BRAHMS_LOOP+=3) {

				INT32 impulseIndex__Out;
				DOUBLE impulseValue__Out;
				getImpulse(&amp;(DATAOut<xsl:value-of select="@name"/>[0]), i_BRAHMS_LOOP, impulseIndex__Out, impulseValue__Out);
				// add the remapped impulse to the output
				addImpulse(OUT<xsl:value-of select="@name"/>, connectivityC2D[impulseIndex__Out], impulseValue__Out);

			}
			PORTOut<xsl:value-of select="@name"/>.setContent(&amp;OUT<xsl:value-of select="@name"/>[0], OUT<xsl:value-of select="@name"/>.size());
</xsl:template>

</xsl:stylesheet>
