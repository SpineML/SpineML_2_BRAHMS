<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="defineImpulsePorts">
vector &lt; spikes::Input &gt; PORT<xsl:value-of select="@name"/>;
vector &lt; DOUBLE &gt; <xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="defineImpulsePorts">
spikes::Output PORTOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="resizeReceive">
<xsl:text>		</xsl:text><xsl:value-of select="@name"/>.resize(numEl,0);
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPorts">
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numElements*30);
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPortsWU">
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numConn*30);
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="createImpulseRecvPorts">
				set = iif.getSet("<xsl:value-of select="@name"/>");
				numInputs = iif.getNumberOfPorts(set);
				PORT<xsl:value-of select="@name"/>.resize(numInputs);
				for (int i = 0; i &lt; numInputs; ++i) {
					PORT<xsl:value-of select="@name"/>[i].selectSet(set);
					PORT<xsl:value-of select="@name"/>[i].attach(hComponent, i);
					
				}
				
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePorts">
			vector &lt; INT32* &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i = 0; i &lt; PORT<xsl:value-of select="@name"/>.size(); ++i) {
				COUNT<xsl:value-of select="@name"/>[i] = PORT<xsl:value-of select="@name"/>[i].getContent(DATA<xsl:value-of select="@name"/>[i]);
			}
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="serviceImpulsePorts">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; INT32 &gt; DATAOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePortsRemap">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; INT32 &gt; &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; DOUBLE &gt; &gt; DATAval<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i = 0; i &lt; PORT<xsl:value-of select="@name"/>.size(); ++i) {
				COUNT<xsl:value-of select="@name"/>[i] = PORT<xsl:value-of select="@name"/>[i].getContent(TEMP<xsl:value-of select="@name"/>);
				// service Impulses port
				for (int j = 0; j &lt; COUNT<xsl:value-of select="@name"/>[i]; j+=3 /* one int + one double = 3 int */) {
					// extract the values
					INT32 impulseIndex__In;
					DOUBLE impulseValue__In;
					getImpulse(TEMP<xsl:value-of select="@name"/>, j, impulseIndex__In, impulseValue__In);
					// remap the input
					for (int k = 0; k &lt; connectivityS2C[impulseIndex__In].size(); ++k) {
						// add the index from the lookup
						DATA<xsl:value-of select="@name"/>[i].push_back(connectivityS2C[impulseIndex_In][k]);
						// add the value
						DATAval<xsl:value-of select="@name"/>[i].push_back(impulseValue_In);							
					}
				}
			}
			
			// do delay
			if (delayBuffer.size()) {
				// for each spike
				for (UINT32 i = 0; i &lt; DATA<xsl:value-of select="@name"/>.size(); ++i) {
					for (UINT32 j = 0; j &lt; DATA<xsl:value-of select="@name"/>[i].size(); ++j) {
				
						// get delay buffer index to set and add impulse to buffer lists
						delayBuffer[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i][j]])%delayBuffer.size()].push_back(DATA<xsl:value-of select="@name"/>[i][j]);
						delayedImpulseVals[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i][j]])%delayBuffer.size()].push_back(DATAval<xsl:value-of select="@name"/>[i][j]);
				
					}				
				}
			
			}
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
			for (INT32 i = 0; i &lt; DATAOut<xsl:value-of select="@name"/>.size(); i+=3) {
			
				INT32 impulseIndex__Out;
				DOUBLE impulseValue__Out;
				getImpulse(&amp;(DATAOut<xsl:value-of select="@name"/>[0]), i, impulseIndex__Out, impulseValue__Out);
				// add the remapped impulse to the output
				addImpulse(OUT<xsl:value-of select="@name"/>, connectivityC2D[impulseIndex__Out], impulseValue__Out);

			}	
			PORTOut<xsl:value-of select="@name"/>.setContent(&amp;OUT<xsl:value-of select="@name"/>[0], OUT<xsl:value-of select="@name"/>.size());
</xsl:template>

</xsl:stylesheet>
