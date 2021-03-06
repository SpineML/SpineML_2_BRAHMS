<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:StateVariable" mode="defineStateVariable">
	vector &lt;  double &gt; <xsl:value-of select="@name"/>;
	string <xsl:value-of select="@name"/>_BINARY_FILE_NAME;<!-- A string to store explicit data binary file name from which the states are read in. -->
	string <xsl:value-of select="@name"/>_BINARY_FILE_NAME_OUT;<!-- A string to store explicit data binary file name to which the states are written (in spineml_state_dir). -->
</xsl:template>

<xsl:template match="SMLCL:StateVariable" mode="writeoutStateVariable">
			// Write variable name: <xsl:value-of select="@name"/> into a file.
			{<!-- Job 1 - open a suitably named file. -->
				unsigned char copy_buffer_BRAHMS[1024] = "";
				FILE* <xsl:value-of select="@name"/>_svfile;
				string <xsl:value-of select="@name"/>_fileName = <xsl:value-of select="@name"/>_BINARY_FILE_NAME_OUT;
#ifdef MAKE_BACKUP_OF_ORIGINAL_STATE
				<!-- If there's was existing file, then copy it to a backup here? -->
				<xsl:value-of select="@name"/>_svfile = fopen (<xsl:value-of select="@name"/>_fileName.c_str(), "rb");
				if (<xsl:value-of select="@name"/>_svfile) {
					<!-- Opened file as expected, so copy this into a backup. -->
					string <xsl:value-of select="@name"/>_fileName_backup = <xsl:value-of select="@name"/>_fileName + ".bu";
					FILE* <xsl:value-of select="@name"/>_svfile_backup;
					<xsl:value-of select="@name"/>_svfile_backup = fopen (<xsl:value-of select="@name"/>_fileName_backup.c_str(), "wb");
					if (!<xsl:value-of select="@name"/>_svfile) {
						berr &lt;&lt; "Could not open state variable backup file: " &lt;&lt; <xsl:value-of select="@name"/>_fileName_backup;
					}
					<!-- copy here -->
					size_t bytes_copied_BRAHMS = 0;
					size_t bytes_really_copied = 0;
					while ((bytes_copied_BRAHMS = fread (copy_buffer_BRAHMS, 1, 1024, <xsl:value-of select="@name"/>_svfile)) > 0) {
						bytes_really_copied = fwrite (copy_buffer_BRAHMS, 1, bytes_copied_BRAHMS, <xsl:value-of select="@name"/>_svfile_backup);
						if (bytes_really_copied != bytes_copied_BRAHMS) {
							berr &lt;&lt; "Error making state variable backup file: " &lt;&lt; <xsl:value-of select="@name"/>_fileName_backup;
						}
					}
					fclose (<xsl:value-of select="@name"/>_svfile_backup);
					fclose (<xsl:value-of select="@name"/>_svfile);
				}
#endif
				<!-- Now we've made a backup of the original model state, we can write out the new state. -->
				<xsl:value-of select="@name"/>_svfile = fopen (<xsl:value-of select="@name"/>_fileName.c_str(), "wb");
				if (!<xsl:value-of select="@name"/>_svfile) {
					berr &lt;&lt; "Could not open state variable file: " &lt;&lt; <xsl:value-of select="@name"/>_fileName;
				}
				<!-- Job 2 - write index and data value into the file -->
				int writertn_BRAHMS = 0, writeiter_BRAHMS = 0;
				while (writeiter_BRAHMS &lt; this-&gt;<xsl:value-of select="@name"/>.size()) {
					writertn_BRAHMS = fwrite (reinterpret_cast&lt;const char*&gt;(&amp;writeiter_BRAHMS), sizeof(int), 1, <xsl:value-of select="@name"/>_svfile);
					if (writertn_BRAHMS != 1) {
						berr &lt;&lt; "Failed to write index into " &lt;&lt; <xsl:value-of select="@name"/>_fileName &lt;&lt; ". Wrote " &lt;&lt; writertn_BRAHMS &lt;&lt; " ints, rather than 1";
					}
					writertn_BRAHMS = fwrite (reinterpret_cast&lt;const char*&gt;(&amp;this-&gt;<xsl:value-of select="@name"/>[writeiter_BRAHMS]), sizeof(double), 1, <xsl:value-of select="@name"/>_svfile);
					if (writertn_BRAHMS != 1) {
						berr &lt;&lt; "Failed to write data into " &lt;&lt; <xsl:value-of select="@name"/>_fileName &lt;&lt; ". Wrote " &lt;&lt; writertn_BRAHMS &lt;&lt; " doubles, rather than 1";
					}
					++writeiter_BRAHMS;
				}
				<!-- Job 3 - close file. -->
				fclose (<xsl:value-of select="@name"/>_svfile);
			}
</xsl:template>

<xsl:template match="SMLCL:StateVariable" mode="assignStateVariable"><xsl:text>
			</xsl:text>
			<!-- if it is a random variable -->
			// Any state variable means that we can't optimise alltoall weight update components:
			this-&gt;allParamsDelaysAreFixedValue = false;
			{
			bool finishedThis = false;
			// see if not there at all (if so initialise to zero)
			if (!(nodeState.hasField("<xsl:value-of select="@name"/>RANDXOVER2") || \
				nodeState.hasField("<xsl:value-of select="@name"/>OVER2") || \
				nodeState.hasField("<xsl:value-of select="@name"/>RANDX") || \
				nodeState.hasField("<xsl:value-of select="@name"/>") || \
				nodeState.hasField("<xsl:value-of select="@name"/>OVER1") || \
				nodeState.hasField("<xsl:value-of select="@name"/>BIN_FILE_NAME"))) {
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
					this-&gt;rngData_BRAHMS.seed = <xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0)
						this-&gt;rngData_BRAHMS.seed = getTime();
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (RNOR(&amp;this-&gt;rngData_BRAHMS) * val2_BRAHMS) + val1_BRAHMS;
					}
				}
				// if uniform distribution
				if (<xsl:value-of select="@name"/>[0] == 2) {
					val1_BRAHMS = <xsl:value-of select="@name"/>[1];
					val2_BRAHMS = <xsl:value-of select="@name"/>[2];
					this-&gt;rngData_BRAHMS.seed = <xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0)
						this-&gt;rngData_BRAHMS.seed = getTime();
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (UNI(&amp;this-&gt;rngData_BRAHMS) * (val2_BRAHMS-val1_BRAHMS)) + val1_BRAHMS;
					}
				}
				finishedThis = true;
			}
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER2") &amp;&amp; !finishedThis) {
				if (nodeState.getField("<xsl:value-of select="@name"/>OVER2").getDims()[0] == 1) {<!-- getDims()[0] is x value of dimensions. If it's one, then
				                                                                                       the list is a vector of values for every single element,
														       assumed to be in order OR a scalar. -->
					<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>OVER2").getArrayDOUBLE();
					if (<xsl:value-of select="@name"/>.size() == 1) {
						<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, <xsl:value-of select="@name"/>[0]);
					} else if (<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {<!-- Fix to allow subset of indices to be assigned. -->
						berr &lt;&lt; "State Variable <xsl:value-of select="@name"/> has incorrect dimensions (Its size is " &lt;&lt; <xsl:value-of select="@name"/>.size() &lt;&lt; ", not " &lt;&lt; numEl_BRAHMS &lt;&lt; ")";
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
					this-&gt;rngData_BRAHMS.seed = <xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0)
						this-&gt;rngData_BRAHMS.seed = getTime();
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (RNOR(&amp;this-&gt;rngData_BRAHMS) * val2_BRAHMS) + val1_BRAHMS;
					}
				}
				// if uniform distribution
				if (<xsl:value-of select="@name"/>[0] == 2) {
					val1_BRAHMS = <xsl:value-of select="@name"/>[1];
					val2_BRAHMS = <xsl:value-of select="@name"/>[2];
					this-&gt;rngData_BRAHMS.seed = <xsl:value-of select="@name"/>[3];
					if (this-&gt;rngData_BRAHMS.seed == 0)
						this-&gt;rngData_BRAHMS.seed = getTime();
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, 0);
					for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {
						<xsl:value-of select="@name"/>[i_BRAHMS] = (UNI(&amp;this-&gt;rngData_BRAHMS) * (val2_BRAHMS-val1_BRAHMS)) + val1_BRAHMS;
					}
				}
			}

			if (nodeState.hasField("<xsl:value-of select="@name"/>") &amp;&amp; !finishedThis) {
			<xsl:value-of select="@name"/> = nodeState.getField("<xsl:value-of select="@name"/>").getArrayDOUBLE();
				if (<xsl:value-of select="@name"/>.size() == 1) {
					<xsl:value-of select="@name"/>.resize(numEl_BRAHMS, <xsl:value-of select="@name"/>[0]);
				} else if (<xsl:value-of select="@name"/>.size() != numEl_BRAHMS) {
					berr &lt;&lt; "State Variable <xsl:value-of select="@name"/> has incorrect dimensions (Its size is " &lt;&lt; <xsl:value-of select="@name"/>.size() &lt;&lt; ", not " &lt;&lt; numEl_BRAHMS &lt;&lt; ")";
				}
			}

			if (nodeState.hasField("<xsl:value-of select="@name"/>BIN_FILE_NAME") &amp;&amp; !finishedThis) {
			        if (!nodeState.hasField("<xsl:value-of select="@name"/>BIN_NUM_ELEMENTS")) {
				        berr &lt;&lt; "Found a binary file name without corresponding binary number of elements.";
				}
				<xsl:value-of select="@name"/>_BINARY_FILE_NAME = nodeState.getField("<xsl:value-of select="@name"/>BIN_FILE_NAME").getSTRING();
				int __temp_num_property_elements = nodeState.getField("<xsl:value-of select="@name"/>BIN_NUM_ELEMENTS").getINT32();

				// open the file for reading
				FILE * binfile;

				string fileName = modelDirectory_BRAHMS + "/" + <xsl:value-of select="@name"/>_BINARY_FILE_NAME;
				binfile = fopen(fileName.c_str(),"rb");
				if (!binfile) {
					berr &lt;&lt; "Could not open properties list file: " &lt;&lt; fileName;
				}

				<xsl:value-of select="@name"/>.resize(__temp_num_property_elements);
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
					    berr &lt;&lt; "Error loading binary state variable property <xsl:value-of select="@name"/>: index "
						 &lt;&lt; __temp_property_list_indices[i_BRAHMS] &lt;&lt; " out of range";
					}
					<xsl:value-of select="@name"/>[__temp_property_list_indices[i_BRAHMS]] = __temp_property_list_values[i_BRAHMS];
				}
			}

			<!-- OVER1 always sparse (overrides value with a non-complete explicit list) -->
			if (nodeState.hasField("<xsl:value-of select="@name"/>OVER1") &amp;&amp; !finishedThis)
			{
				vector &lt; double &gt; __tempInputValues__;
				__tempInputValues__ = nodeState.getField("<xsl:value-of select="@name"/>OVER1").getArrayDOUBLE();
				// since OVER1 always means sparse Values
				if (<xsl:value-of select="@name"/>.size() == 1) {<!-- possibly unnecessary test? -->
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
