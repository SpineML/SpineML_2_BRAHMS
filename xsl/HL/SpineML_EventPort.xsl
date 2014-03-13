<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:EventReceivePort" mode="defineEventPorts">
vector &lt; spikes::Input &gt; PORT<xsl:value-of select="@name"/>;
</xsl:template>
<xsl:template match="SMLCL:EventSendPort" mode="defineEventPorts">
spikes::Output PORTOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="createEventSendPorts">
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numElements*10);
</xsl:template>

<xsl:template match="SMLCL:EventReceivePort" mode="createEventRecvPorts">
				set = iif.getSet("<xsl:value-of select="@name"/>");
				numInputs = iif.getNumberOfPorts(set);
				PORT<xsl:value-of select="@name"/>.resize(numInputs);
				for (int i = 0; i &lt; numInputs; ++i) {
					PORT<xsl:value-of select="@name"/>[i].selectSet(set);
					PORT<xsl:value-of select="@name"/>[i].attach(hComponent, i);
					
				}
</xsl:template>

<xsl:template match="SMLCL:EventReceivePort" mode="serviceEventPorts">
			vector &lt; INT32* &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i = 0; i &lt; PORT<xsl:value-of select="@name"/>.size(); ++i) {
				COUNT<xsl:value-of select="@name"/>[i] = PORT<xsl:value-of select="@name"/>[i].getContent(DATA<xsl:value-of select="@name"/>[i]);
			}
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="serviceEventPorts">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; INT32 &gt; DATAOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:EventReceivePort" mode="serviceEventPortsRemap">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; INT32 &gt; &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i = 0; i &lt; PORT<xsl:value-of select="@name"/>.size(); ++i) {
				COUNT<xsl:value-of select="@name"/>[i] = PORT<xsl:value-of select="@name"/>[i].getContent(TEMP<xsl:value-of select="@name"/>);
				// service events port
				for (int j = 0; j &lt; COUNT<xsl:value-of select="@name"/>[i]; ++j) {
					// remap the input
					for (int k = 0; k &lt; connectivityS2C[TEMP<xsl:value-of select="@name"/>[j]].size(); ++k) {
						DATA<xsl:value-of select="@name"/>[i].push_back(connectivityS2C[TEMP<xsl:value-of select="@name"/>[j]][k]);						
					}
				}
			}
			
			// do delay
			if (delayBuffer.size()) {
				// for each spike
				for (UINT32 i = 0; i &lt; DATA<xsl:value-of select="@name"/>.size(); ++i) {
					for (UINT32 j = 0; j &lt; DATA<xsl:value-of select="@name"/>[i].size(); ++j) {
				
						// get delay buffer index to set and add spike to buffer
						delayBuffer[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i][j]])%delayBuffer.size()].push_back(DATA<xsl:value-of select="@name"/>[i][j]);
				
					}				
				}
			
			}
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="serviceEventPortsRemap">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; INT32 &gt; DATAOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="outputEventPorts">
				PORTOut<xsl:value-of select="@name"/>.setContent(&amp;DATAOut<xsl:value-of select="@name"/>[0], DATAOut<xsl:value-of select="@name"/>.size());
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="outputEventPortsRemap">

			vector &lt; INT32 &gt; OUT<xsl:value-of select="@name"/>;
			for (int i = 0; i &lt; DATAOut<xsl:value-of select="@name"/>.size(); ++i) {

				OUT<xsl:value-of select="@name"/>.push_back(connectivityC2D[DATAOut<xsl:value-of select="@name"/>[i]]);

			}	
			PORTOut<xsl:value-of select="@name"/>.setContent(&amp;OUT<xsl:value-of select="@name"/>[0], OUT<xsl:value-of select="@name"/>.size());
</xsl:template>

</xsl:stylesheet>
