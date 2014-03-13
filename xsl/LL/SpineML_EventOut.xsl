<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:EventOut">
					//EventOut
//bout &lt;&lt; "SPIKE!" &lt;&lt; " from <xsl:value-of select="//SMLCL:ComponentClass/@name"/>" &lt;&lt; D_WARN;
					DATAOut<xsl:value-of select="@port"/>.push_back(num_BRAHMS);
</xsl:template>

</xsl:stylesheet>
