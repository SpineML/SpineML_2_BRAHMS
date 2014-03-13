<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Parameter" mode="defineParameter">
vector &lt; double &gt; <xsl:value-of select="@name"/>; 
</xsl:template>

<xsl:template match="SMLCL:Parameter" mode="assignParameter">
			<!-- if it is a random variable -->
			{
			bool finishedThis = false;
			if (nodeState.hasField("<xsl:value-of select="@name"/>RANDXOVER2")) {
				<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>RANDXOVER2").getArrayDOUBLE();
				float val1 = 0;
				float val2 = 1;
				// if normal distribution
				if (<xsl:value-of select="@name"/>[0] == 1) {
					val1 = <xsl:value-of select="@name"/>[1];
					val2 = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					<xsl:value-of select="@name"/>.resize(numEl, 0);
					for (UINT32 i = 0; i &lt; numEl; ++i) {
						<xsl:value-of select="@name"/>[i] = (RNOR * val2) + val1;
					}
				}
				// if uniform distribution
				if (<xsl:value-of select="@name"/>[0] == 2) {
					val1 = <xsl:value-of select="@name"/>[1];
					val2 = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					<xsl:value-of select="@name"/>.resize(numEl, 0);
					for (UINT32 i = 0; i &lt; numEl; ++i) {
						<xsl:value-of select="@name"/>[i] = (UNI * (val2-val1)) + val1;
					}
				}
				finishedThis = true;
			}
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER2") &amp;&amp; !finishedThis) {
				if (nodeState.getField("<xsl:value-of select="@name"/>OVER2").getDims()[0] == 1) {
					<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>OVER2").getArrayDOUBLE(); 
					if (<xsl:value-of select="@name"/>.size() == 1) {
						<xsl:value-of select="@name"/>.resize(numEl, <xsl:value-of select="@name"/>[0]);
					} else if (<xsl:value-of select="@name"/>.size() != numEl) {
						berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has incorrect dimensions";
					}
					finishedThis = true;
				}
				
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>RANDX") &amp;&amp; !finishedThis) {

				<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>RANDX").getArrayDOUBLE();				
				float val1 = 0;
				float val2 = 1;
				// if normal distribution
				if (<xsl:value-of select="@name"/>[0] == 1) {
					val1 = <xsl:value-of select="@name"/>[1];
					val2 = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					<xsl:value-of select="@name"/>.resize(numEl, 0);
					for (UINT32 i = 0; i &lt; numEl; ++i) {
						<xsl:value-of select="@name"/>[i] = (RNOR * val2) + val1;
					}
				}
				// if uniform distribution
				if (<xsl:value-of select="@name"/>[0] == 2) {
					val1 = <xsl:value-of select="@name"/>[1];
					val2 = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					<xsl:value-of select="@name"/>.resize(numEl, 0);
					for (UINT32 i = 0; i &lt; numEl; ++i) {
						<xsl:value-of select="@name"/>[i] = (UNI * (val2-val1)) + val1;
					}
				}
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>") &amp;&amp; !finishedThis) 
			{ 
			<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>").getArrayDOUBLE(); 
				if (<xsl:value-of select="@name"/>.size() == 1) {
					<xsl:value-of select="@name"/>.resize(numEl, <xsl:value-of select="@name"/>[0]);
				} else if (<xsl:value-of select="@name"/>.size() != numEl) {
					berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has incorrect dimensions";
				}
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER1") &amp;&amp; !finishedThis) 
			{
				vector &lt; double &gt; __tempInputValues__;
				__tempInputValues__ = nodeState.getField("<xsl:value-of select="@name"/>OVER1").getArrayDOUBLE();
				// since OVER1 always means sparse Values
				if (<xsl:value-of select="@name"/>.size() == 1) {
					<xsl:value-of select="@name"/>.resize(numEl, <xsl:value-of select="@name"/>[0]);
				}
				if (<xsl:value-of select="@name"/>.size() != numEl) {berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has a ValueList override but no base Values";}
				for (UINT32 i = 0; i &lt; __tempInputValues__.size(); i += 2) {
					if (__tempInputValues__[i] > numEl-1) {berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has ValueList index " &lt;&lt; float(i)&lt;&lt; " (value of " &lt;&lt; float(__tempInputValues__[i]) &lt;&lt; ") out of range";}
					<xsl:value-of select="@name"/>[__tempInputValues__[i]] = __tempInputValues__[i+1];
				}
			
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER2") &amp;&amp; !finishedThis) 
			{
				vector &lt; double &gt; __tempInputValues__;
				__tempInputValues__ = nodeState.getField("<xsl:value-of select="@name"/>OVER2").getArrayDOUBLE();
				// OVER2 here means sparse Values
				if (<xsl:value-of select="@name"/>.size() != numEl) {berr &lt;&lt; "Experiment Parameter <xsl:value-of select="@name"/> has a ValueList override but no base Values";}
				for (UINT32 i = 0; i &lt; __tempInputValues__.size(); i += 2) {
					if (__tempInputValues__[i] > numEl-1) {berr &lt;&lt; "Experiment Parameter <xsl:value-of select="@name"/> has ValueList index " &lt;&lt; float(i)&lt;&lt; " (value of " &lt;&lt; float(__tempInputValues__[i]) &lt;&lt; ") out of range";}
					<xsl:value-of select="@name"/>[__tempInputValues__[i]] = __tempInputValues__[i+1];
				}
			
			}
			// output the values:
			/*bout &lt;&lt; "<xsl:value-of select="@name"/>" &lt;&lt; D_WARN;
			for (UINT32 i = 0; i &lt; <xsl:value-of select="@name"/>.size(); ++i) {
				bout &lt;&lt; float(<xsl:value-of select="@name"/>[i]) &lt;&lt; D_WARN;
			}*/
			}
			
</xsl:template>


</xsl:stylesheet>
