<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:StateVariable" mode="defineStateVariable">
vector &lt;  double &gt; <xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:StateVariable" mode="assignStateVariable"><xsl:text>
			</xsl:text>
			<!-- if it is a random variable -->
			{
			bool finishedThis = false;
			// see if not there at all (if so initialise to zero)
			if (!(nodeState.hasField("<xsl:value-of select="@name"/>RANDXOVER2") || \
				nodeState.hasField("<xsl:value-of select="@name"/>OVER2") || \
				nodeState.hasField("<xsl:value-of select="@name"/>RANDX") || \
				nodeState.hasField("<xsl:value-of select="@name"/>") || \
				nodeState.hasField("<xsl:value-of select="@name"/>OVER1"))) {
				<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
			}
				
			if (nodeState.hasField("<xsl:value-of select="@name"/>RANDXOVER2")) {
				<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>RANDXOVER2").getArrayDOUBLE();
				float val1_BRAHMS = 0;
				float val2_BRAHMS = 1;
				// if normal distribution
				if (<xsl:value-of select="@name"/>[0] == 1) {
					val1_BRAHMS = <xsl:value-of select="@name"/>[1];
					val2_BRAHMS = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					if (seed == 0)
						seed = getTime();	
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (RNOR * val2_BRAHMS) + val1_BRAHMS;
					}
				}
				// if uniform distribution
				if (<xsl:value-of select="@name"/>[0] == 2) {
					val1_BRAHMS = <xsl:value-of select="@name"/>[1];
					val2_BRAHMS = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					if (seed == 0)
						seed = getTime();	
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (UNI * (val2_BRAHMS-val1_BRAHMS)) + val1_BRAHMS;
					}
				}
				finishedThis = true;
			}
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER2") &amp;&amp; !finishedThis) {
				if (nodeState.getField("<xsl:value-of select="@name"/>OVER2").getDims()[0] == 1) {
					<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>OVER2").getArrayDOUBLE(); 
					if (<xsl:value-of select="@name"/>.size() == 1) {
						<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, <xsl:value-of select="@name"/>[0]);
					} else if (<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {
						berr &lt;&lt; "State Variable <xsl:value-of select="@name"/> has incorrect dimensions";
					}
					finishedThis = true;
				}
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>RANDX") &amp;&amp; !finishedThis) {

				<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>RANDX").getArrayDOUBLE();				
				float val1_BRAHMS = 0;
				float val2_BRAHMS = 1;
				// if normal distribution
				if (<xsl:value-of select="@name"/>[0] == 1) {
					val1_BRAHMS = <xsl:value-of select="@name"/>[1];
					val2_BRAHMS = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					if (seed == 0)
						seed = getTime();	
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (RNOR * val2_BRAHMS) + val1_BRAHMS;
					}
				}
				// if uniform distribution
				if (<xsl:value-of select="@name"/>[0] == 2) {
					val1_BRAHMS = <xsl:value-of select="@name"/>[1];
					val2_BRAHMS = <xsl:value-of select="@name"/>[2];
					seed = <xsl:value-of select="@name"/>[3];
					if (seed == 0)
						seed = getTime();	
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (UNI * (val2_BRAHMS-val1_BRAHMS)) + val1_BRAHMS;
					}
				}
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>") &amp;&amp; !finishedThis) 
			{ 
			<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>").getArrayDOUBLE(); 
				if (<xsl:value-of select="@name"/>.size() == 1) {
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, <xsl:value-of select="@name"/>[0]);
				} else if (<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {
					berr &lt;&lt; "State Variable <xsl:value-of select="@name"/> has incorrect dimensions";
				}
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER1") &amp;&amp; !finishedThis) 
			{
				vector &lt; double &gt; __tempInputValues__;
				__tempInputValues__ = nodeState.getField("<xsl:value-of select="@name"/>OVER1").getArrayDOUBLE();
				// since OVER1 always means sparse Values
				if (<xsl:value-of select="@name"/>.size() == 1) {
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, <xsl:value-of select="@name"/>[0]);
				}
				if (<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {berr &lt;&lt; "State Variable <xsl:value-of select="@name"/> has a ValueList override but no base Values";}
				for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; __tempInputValues__.size(); i_BRAHMS += 2) {
					if (__tempInputValues__[i_BRAHMS] > numEl_BRAHMS-1) {berr &lt;&lt; "State Variable <xsl:value-of select="@name"/> has ValueList index " &lt;&lt; float(i_BRAHMS)&lt;&lt; " (value of " &lt;&lt; float(__tempInputValues__[i_BRAHMS]) &lt;&lt; ") out of range";}
					<xsl:value-of select="@name"/>[__tempInputValues__[i_BRAHMS]] = __tempInputValues__[i_BRAHMS+1];
				}
			
			}
			
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER2") &amp;&amp; !finishedThis) 
			{
				vector &lt; double &gt; __tempInputValues__;
				__tempInputValues__ = nodeState.getField("<xsl:value-of select="@name"/>OVER2").getArrayDOUBLE();
				// OVER2 here means sparse Values
				if (<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {berr &lt;&lt; "Experiment State Variable <xsl:value-of select="@name"/> has a ValueList override but no base Values";}
				for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; __tempInputValues__.size(); i_BRAHMS += 2) {
					if (__tempInputValues__[i_BRAHMS] > numEl_BRAHMS-1) {berr &lt;&lt; "Experiment State Variable <xsl:value-of select="@name"/> has ValueList index " &lt;&lt; float(i_BRAHMS)&lt;&lt; " (value of " &lt;&lt; float(__tempInputValues__[i_BRAHMS]) &lt;&lt; ") out of range";}
					<xsl:value-of select="@name"/>[__tempInputValues__[i_BRAHMS]] = __tempInputValues__[i_BRAHMS+1];
				}
			
			}
			
			// output the values:
			/*bout &lt;&lt; "<xsl:value-of select="@name"/>" &lt;&lt; D_WARN;
			for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; <xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
				bout &lt;&lt; float(<xsl:value-of select="@name"/>[i_BRAHMS]) &lt;&lt; D_WARN;
			}*/
			}
</xsl:template>

</xsl:stylesheet>
