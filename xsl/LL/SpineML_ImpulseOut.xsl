<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:ImpulseOut">
					//ImpulseOut
					//bout &lt;&lt; "IMPULSE!" &lt;&lt; " from <xsl:value-of select="//SMLCL:ComponentClass/@name"/>" &lt;&lt; D_WARN;
                                        if (num_BRAHMS &gt;= this-&gt;<xsl:value-of select="@port"/>.size()) {
                                        berr &lt;&lt; "Can't index <xsl:value-of select="@port"/>[" &lt;&lt; num_BRAHMS
					     &lt;&lt; "]! Is the weight list a different length from the number of connections?";
                                        }
					addImpulse(DATAOut<xsl:value-of select="@port"/>, num_BRAHMS, this-&gt;<xsl:value-of select="@port"/>[num_BRAHMS]);
</xsl:template>

</xsl:stylesheet>
