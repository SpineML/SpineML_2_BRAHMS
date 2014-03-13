<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:AnalogReceivePort" mode="defineAnalogPorts">
numeric::Input PORT<xsl:value-of select="@name"/>;
vector &lt; double &gt; <xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:AnalogReducePort" mode="defineAnalogPorts">
vector &lt; numeric::Input &gt; PORT<xsl:value-of select="@name"/>;
vector &lt; double &gt; <xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="defineAnalogPorts">
numeric::Output PORT<xsl:value-of select="@name"/>;
//if using an alias then create the output variable
<xsl:variable name="portname" select="@name"/>
<xsl:for-each select="/SMLCL:SpineML/SMLCL:ComponentClass/SMLCL:Dynamics/SMLCL:Alias">
<xsl:if test="contains($portname, @name) and string-length($portname) = string-length(@name)">
vector &lt; double &gt; <xsl:value-of select="@name"/>;
</xsl:if>
</xsl:for-each>
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="createAnalogSendPorts">
				PORT<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORT<xsl:value-of select="@name"/>.create(hComponent);
				PORT<xsl:value-of select="@name"/>.setStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElements).cdims());
</xsl:template>

<xsl:template match="SMLCL:AnalogReceivePort" mode="createAnalogRecvPorts">
				PORT<xsl:value-of select="@name"/>.attach(hComponent, "<xsl:value-of select="@name"/>");
				PORT<xsl:value-of select="@name"/>.validateStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElements).cdims());
</xsl:template>

<xsl:template match="SMLCL:AnalogReducePort" mode="createAnalogReducePorts">
				set = iif.getSet("<xsl:value-of select="@name"/>");
				numInputs = iif.getNumberOfPorts(set);
				PORT<xsl:value-of select="@name"/>.resize(numInputs);
				<xsl:value-of select="@name"/>.resize(numElements,0);
				for (int i = 0; i &lt; numInputs; ++i) {
					PORT<xsl:value-of select="@name"/>[i].selectSet(set);
					PORT<xsl:value-of select="@name"/>[i].attach(hComponent, i);
					PORT<xsl:value-of select="@name"/>[i].validateStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElements).cdims());
				}

</xsl:template>

<xsl:template match="SMLCL:AnalogReceivePort" mode="serviceAnalogPorts">
			<xsl:value-of select="@name"/>.resize(numElements);
			memcpy(&amp;<xsl:value-of select="@name"/>[0], PORT<xsl:value-of select="@name"/>.getContent(), numElements*sizeof(DOUBLE));
</xsl:template>
<xsl:template match="SMLCL:AnalogReducePort" mode="serviceAnalogPorts">
		DOUBLE* DATA<xsl:value-of select="@name"/>;
			for (int i = 0; i &lt; PORT<xsl:value-of select="@name"/>.size(); ++i) {
				DATA<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>[i].getContent();
				for (int j = 0; j &lt; <xsl:value-of select="@name"/>.size(); ++j) {
					// reset value then sum inputs
					if (i == 0) <xsl:value-of select="@name"/>[j] = 0;
					<xsl:value-of select="@name"/>[j] += DATA<xsl:value-of select="@name"/>[j];
				}
			}
			<!---->
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="serviceAnalogPorts">
<!-- blank for now -->
</xsl:template>

<xsl:template match="SMLCL:AnalogReceivePort" mode="serviceAnalogPortsRemap">
	<!-- -->DOUBLE * TEMP<xsl:value-of select="@name"/>;
			TEMP<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>.getContent();
			for (int i = 0; i &lt; connectivityS2C.size(); ++i) {
				for (int j = 0; j &lt; connectivityS2C[i].size(); ++j) {
					<xsl:value-of select="@name"/>[i] = TEMP<xsl:value-of select="@name"/>[connectivityS2C[i][j]];
				}
			}
</xsl:template>

<xsl:template match="SMLCL:AnalogReducePort" mode="serviceAnalogPortsRemap">
			DOUBLE* DATA<xsl:value-of select="@name"/>;
			for (int i = 0; i &lt; PORT<xsl:value-of select="@name"/>.size(); ++i) {
				DATA<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>[i].getContent();
				for (int j = 0; j &lt; connectivityS2C.size(); ++j) {
					// reset value then sum inputs
					if (i == 0) <xsl:value-of select="@name"/>[j] = 0;
					for (int k = 0; k &lt; connectivityS2C[j].size(); ++k) {
						<xsl:value-of select="@name"/>[j] += DATA<xsl:value-of select="@name"/>[connectivityS2C[j][k]];
					}
				}
			}
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="outputAnalogPorts">
			PORT<xsl:value-of select="@name"/>.setContent(&amp;<xsl:value-of select="@name"/>[0]);
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="outputAnalogPortsRemap">
			vector &lt; DOUBLE &gt; OUT<xsl:value-of select="@name"/>;
			OUT<xsl:value-of select="@name"/>.resize(numElements, 0);
			for (int i = 0; i &lt; numEl; ++i) {

				OUT<xsl:value-of select="@name"/>[connectivityC2D[i]] += <xsl:value-of select="@name"/>[i];
			}	

			PORT<xsl:value-of select="@name"/>.setContent(&amp;OUT<xsl:value-of select="@name"/>[0]);
</xsl:template>

</xsl:stylesheet>
