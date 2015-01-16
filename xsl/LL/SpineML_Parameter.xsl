<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:Parameter" mode="defineParameter">
	vector &lt; double &gt; <xsl:value-of select="@name"/>;
	double * <xsl:value-of select="@name"/>S;
</xsl:template>

<xsl:template match="SMLCL:Parameter" mode="assignPointer">
	<xsl:value-of select="@name"/>S = <xsl:value-of select="@name"/>.size() == 1 ? &amp;<xsl:value-of select="@name"/>[0] : &amp;<xsl:value-of select="@name"/>[num_BRAHMS];
</xsl:template>

<xsl:template match="SMLCL:Parameter" mode="assignParameter">
			<!-- if it is a random variable -->
			{
			bool finishedThis = false;
			if (nodeState.hasField("<xsl:value-of select="@name"/>RANDXOVER2")) {
				this-&gt;<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>RANDXOVER2").getArrayDOUBLE();
				float val1_BRAHMS = 0;
				float val2_BRAHMS = 1;
				// if normal distribution
				if (this-&gt;<xsl:value-of select="@name"/>[0] == 1) {
					val1_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[1];
					val2_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[2];
					this-&gt;rngData_BRAHMS.seed = <xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0) {
						this-&gt;rngData_BRAHMS.seed = getTime();
					}
					this-&gt;<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						this-&gt;<xsl:value-of select="@name"/>[i_BRAHMS] = (RNOR(&amp;this-&gt;rngData_BRAHMS) * val2_BRAHMS) + val1_BRAHMS;
					}
				}
				// if uniform distribution
				if (this-&gt;<xsl:value-of select="@name"/>[0] == 2) {
					val1_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[1];
					val2_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[2];
					this-&gt;rngData_BRAHMS.seed = this-&gt;<xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0) {
						this-&gt;rngData_BRAHMS.seed = getTime();
					}
					this-&gt;<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						this-&gt;<xsl:value-of select="@name"/>[i_BRAHMS] = (UNI(&amp;this-&gt;rngData_BRAHMS) * (val2_BRAHMS-val1_BRAHMS)) + val1_BRAHMS;
					}
				}
				finishedThis = true;
			}
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER2") &amp;&amp; !finishedThis) {
				if (nodeState.getField("<xsl:value-of select="@name"/>OVER2").getDims()[0] == 1) {
					this-&gt;<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>OVER2").getArrayDOUBLE();
					if (this-&gt;<xsl:value-of select="@name"/>.size() == 1) {
						this-&gt;<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, <xsl:value-of select="@name"/>[0]);
					} else if (this-&gt;<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {
						berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has incorrect dimensions (Its size is " &lt;&lt; this-&gt;<xsl:value-of select="@name"/>.size() &lt;&lt; ", not " &lt;&lt; numEl_BRAHMS &lt;&lt; ")";
					}
					finishedThis = true;
				}
			}

			if (nodeState.hasField("<xsl:value-of select="@name"/>RANDX") &amp;&amp; !finishedThis) {

				this-&gt;<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>RANDX").getArrayDOUBLE();
				float val1_BRAHMS = 0;
				float val2_BRAHMS = 1;
				// if normal distribution
				if (this-&gt;<xsl:value-of select="@name"/>[0] == 1) {
					val1_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[1];
					val2_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[2];
					this-&gt;rngData_BRAHMS.seed = this-&gt;<xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0) {
						this-&gt;rngData_BRAHMS.seed = getTime();
					}
					this-&gt;<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						this-&gt;<xsl:value-of select="@name"/>[i_BRAHMS] = (RNOR(&amp;this-&gt;rngData_BRAHMS) * val2_BRAHMS) + val1_BRAHMS;
					}
				}
				// if uniform distribution
				if (this-&gt;<xsl:value-of select="@name"/>[0] == 2) {
					val1_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[1];
					val2_BRAHMS = this-&gt;<xsl:value-of select="@name"/>[2];
					this-&gt;rngData_BRAHMS.seed = this-&gt;<xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0) {
						this-&gt;rngData_BRAHMS.seed = getTime();
					}
					this-&gt;<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						this-&gt;<xsl:value-of select="@name"/>[i_BRAHMS] = (UNI(&amp;this-&gt;rngData_BRAHMS) * (val2_BRAHMS-val1_BRAHMS)) + val1_BRAHMS;
					}
				}
			}

			if (nodeState.hasField("<xsl:value-of select="@name"/>") &amp;&amp; !finishedThis)
			{
				this-&gt;<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>").getArrayDOUBLE();
				if (this-&gt;<xsl:value-of select="@name"/>.size() == 1) {
					this-&gt;<xsl:value-of select="@name"/>.resize(1, <xsl:value-of select="@name"/>[0]);
				} else if (this-&gt;<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {
					berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has incorrect dimensions (Its size is " &lt;&lt; <xsl:value-of select="@name"/>.size() &lt;&lt; ", not " &lt;&lt; numEl_BRAHMS &lt;&lt; ")";
				}
			}

			if (nodeState.hasField("<xsl:value-of select="@name"/>BIN_FILE_NAME") &amp;&amp; !finishedThis) {
			        if (!nodeState.hasField("<xsl:value-of select="@name"/>BIN_NUM_ELEMENTS")) {
				        berr &lt;&lt; "Found a binary file name without corresponding binary number of elements.";
				}
				string <xsl:value-of select="@name"/>_BINARY_FILE_NAME = nodeState.getField("<xsl:value-of select="@name"/>BIN_FILE_NAME").getSTRING();
				int __temp_num_property_elements = nodeState.getField("<xsl:value-of select="@name"/>BIN_NUM_ELEMENTS").getINT32();

				// open the file for reading
				FILE * binfile;

				string fileName = modelDirectory_BRAHMS + "/" + <xsl:value-of select="@name"/>_BINARY_FILE_NAME;
				binfile = fopen(fileName.c_str(),"rb");
				if (!binfile) {
					berr &lt;&lt; "Could not open properties list file: " &lt;&lt; fileName;
				}

				this-&gt;<xsl:value-of select="@name"/>.resize(__temp_num_property_elements);
				vector&lt;INT32&gt; __temp_property_list_indices (__temp_num_property_elements, 0);
				vector&lt;DOUBLE&gt; __temp_property_list_values (__temp_num_property_elements, 0);
				for (int i_BRAHMS = 0; i_BRAHMS &lt; __temp_num_property_elements; ++i_BRAHMS) {

					size_t ret_FOR_BRAHMS = fread(&amp;__temp_property_list_indices[i_BRAHMS], sizeof(INT32), 1, binfile);
					if (ret_FOR_BRAHMS == -1) {berr &lt;&lt; "Error loading binary properties: Failed to read an index";}
					ret_FOR_BRAHMS = fread(&amp;__temp_property_list_values[i_BRAHMS], sizeof(DOUBLE), 1, binfile);
					if (ret_FOR_BRAHMS == -1) {berr &lt;&lt; "Error loading binary properties: Failed to read a value";}
				}
				for (int i_BRAHMS = 0; i_BRAHMS &lt; __temp_num_property_elements; ++i_BRAHMS) {
				        if ( __temp_property_list_indices[i_BRAHMS] &gt; __temp_num_property_elements
					    || __temp_property_list_indices[i_BRAHMS] &lt; 0) {
					    berr &lt;&lt; "Error loading parameter binary property <xsl:value-of select="@name"/>: index "
						 &lt;&lt; __temp_property_list_indices[i_BRAHMS] &lt;&lt; " out of range";
					}
					this-&gt;<xsl:value-of select="@name"/>[__temp_property_list_indices[i_BRAHMS]] = __temp_property_list_values[i_BRAHMS];
				}
			}

			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER1") &amp;&amp; !finishedThis)
			{
				vector &lt; double &gt; __tempInputValues__;
				__tempInputValues__ = nodeState.getField("<xsl:value-of select="@name"/>OVER1").getArrayDOUBLE();
				// since OVER1 always means sparse Values
				if (this-&gt;<xsl:value-of select="@name"/>.size() == 1) {
					this-&gt;<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, <xsl:value-of select="@name"/>[0]);
				}
				if (this-&gt;<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {
					berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has a ValueList override but no base Values";
				}
				for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; __tempInputValues__.size(); i_BRAHMS += 2) {
					if (__tempInputValues__[i_BRAHMS] > numEl_BRAHMS-1) {
						berr &lt;&lt; "Parameter <xsl:value-of select="@name"/> has ValueList index " &lt;&lt; float(i_BRAHMS)&lt;&lt; " (value of " &lt;&lt; float(__tempInputValues__[i_BRAHMS]) &lt;&lt; ") out of range";
					}
					this-&gt;<xsl:value-of select="@name"/>[__tempInputValues__[i_BRAHMS]] = __tempInputValues__[i_BRAHMS+1];
				}
			}

			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER2") &amp;&amp; !finishedThis)
			{
				vector &lt; double &gt; __tempInputValues__;
				__tempInputValues__ = nodeState.getField("<xsl:value-of select="@name"/>OVER2").getArrayDOUBLE();
				// OVER2 here means sparse Values
				if (this-&gt;<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {
					berr &lt;&lt; "Experiment Parameter <xsl:value-of select="@name"/> has a ValueList override but no base Values";
				}
				for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; __tempInputValues__.size(); i_BRAHMS += 2) {
					if (__tempInputValues__[i_BRAHMS] > numEl_BRAHMS-1) {
						berr &lt;&lt; "Experiment Parameter <xsl:value-of select="@name"/> has ValueList index " &lt;&lt; float(i_BRAHMS)&lt;&lt; " (value of " &lt;&lt; float(__tempInputValues__[i_BRAHMS]) &lt;&lt; ") out of range";
					}
					this-&gt;<xsl:value-of select="@name"/>[__tempInputValues__[i_BRAHMS]] = __tempInputValues__[i_BRAHMS+1];
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
