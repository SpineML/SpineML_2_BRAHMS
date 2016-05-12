<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
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
<!-- CREATE LOG VECTOR AND MAP AND FILE HANDLE -->
vector &lt; double &gt; <xsl:value-of select="@name"/>LOGVAR;
vector &lt; int &gt; <xsl:value-of select="@name"/>LOGMAP;
FILE * <xsl:value-of select="@name"/>LOGFILE;
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="createSendPortLogs">
<!-- GET LOG INFO AND RESIZE LOG VECTOR -->
			// check for existence of log stateNode
			if (nodeState.hasField("<xsl:value-of select="@name"/>LOG")) {
				// we have a log! Read the data in:
				// check we got some data first
				VDOUBLE tempLogData_BRAHMS = nodeState.getField("<xsl:value-of select="@name"/>LOG").getArrayDOUBLE();
				if (tempLogData_BRAHMS.size() == 0) berr &lt;&lt; "ERROR: log with no indices";
				// if we are logging 'all'
				if (tempLogData_BRAHMS[0] &lt; -0.1) {
					<xsl:value-of select="@name"/>LOGMAP.push_back(-2);
				} else {
				// otherwise
					// resize the logvar:
					<xsl:value-of select="@name"/>LOGVAR.resize(tempLogData_BRAHMS.size(),0);
					// resize the logmap:
					<xsl:value-of select="@name"/>LOGMAP.resize(numEl_BRAHMS,-1);
					// set the logmap values - checking for out of range values
					for (unsigned int i_BRAHMS = 0; i_BRAHMS &lt; tempLogData_BRAHMS.size(); ++i_BRAHMS) {
						if (tempLogData_BRAHMS[i_BRAHMS]+0.5 > numEl_BRAHMS) {
							bout &lt;&lt; "Attempting to log an index out of range" &lt;&lt; D_WARN;
						} else {
							// set in mapping that the i_BRAHMSth log value relates to the tempLogData_BRAHMS[i_BRAHMS]th neuron
							<xsl:value-of select="@name"/>LOGMAP[(int) tempLogData_BRAHMS[i_BRAHMS]] = i_BRAHMS;
						}
					}
				}
				// open the logfile for writing
				string logFileName_BRAHMS = baseNameForLogs_BRAHMS;
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_log.bin");
				<xsl:value-of select="@name"/>LOGFILE = fopen(logFileName_BRAHMS.c_str(),"wb");
			}
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="makeSendPortLogs">
				if (<xsl:value-of select="@name"/>LOGMAP.size() &gt; 0) {
					if (<xsl:value-of select="@name"/>LOGMAP[0] &gt; -1.1) {
						if (<xsl:value-of select="@name"/>LOGMAP[i_BRAHMS]+1)
							<xsl:value-of select="@name"/>LOGVAR[<xsl:value-of select="@name"/>LOGMAP[i_BRAHMS]] = <xsl:value-of select="@name"/>[i_BRAHMS];
					}
				}
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="saveSendPortLogs">
				if (<xsl:value-of select="@name"/>LOGMAP.size() &gt; 0) {
					if (<xsl:value-of select="@name"/>LOGMAP[0] &lt; -1.1) {
						// write data
						size_t written_BRAHMS = fwrite(&amp;<xsl:value-of select="@name"/>[0],sizeof(double),<xsl:value-of select="@name"/>.size(),<xsl:value-of select="@name"/>LOGFILE);
						if (written_BRAHMS != <xsl:value-of select="@name"/>.size()) berr &lt;&lt; "Error writing logfile for " &lt;&lt; baseNameForLogs_BRAHMS &lt;&lt; "_<xsl:value-of select="@name"/>";
					} else {
						// write data
						size_t written_BRAHMS = fwrite(&amp;<xsl:value-of select="@name"/>LOGVAR[0],sizeof(double),<xsl:value-of select="@name"/>LOGVAR.size(),<xsl:value-of select="@name"/>LOGFILE);
						if (written_BRAHMS != <xsl:value-of select="@name"/>LOGVAR.size()) berr &lt;&lt; "Error writing logfile for " &lt;&lt; baseNameForLogs_BRAHMS &lt;&lt; "_<xsl:value-of select="@name"/>";
					}
				}
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="finaliseLogs">
			if (<xsl:value-of select="@name"/>LOGMAP.size() &gt; 0) {
				<!-- WRITE XML FOR LOGS -->
				FILE * <xsl:value-of select="@name"/>LOGREPORT;
				string logFileName_BRAHMS = baseNameForLogs_BRAHMS;
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_logrep.xml");
				<xsl:value-of select="@name"/>LOGREPORT = fopen(logFileName_BRAHMS.c_str(),"w");
				logFileName_BRAHMS = baseNameForLogs_BRAHMS;
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_log.bin");
  			unsigned found = logFileName_BRAHMS.find_last_of("/\\");
  			logFileName_BRAHMS = logFileName_BRAHMS.substr(found+1);
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "&lt;LogReport&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "	&lt;AnalogLog&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogFile&gt;%s&lt;/LogFile&gt;\n",logFileName_BRAHMS.c_str());
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogFileType&gt;binary&lt;/LogFileType&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogEndTime&gt;%f&lt;/LogEndTime&gt;\n",t);
				if (<xsl:value-of select="@name"/>LOGMAP[0] &gt; -1.1) {
					for (unsigned int i = 0; i &lt; <xsl:value-of select="@name"/>LOGMAP.size(); ++i) {
						if (<xsl:value-of select="@name"/>LOGMAP[i] &gt; -0.1) {
							fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogCol index=\"%d\" heading=\"<xsl:value-of select="@name"/>\" dims=\"<!---->
							<xsl:variable name="name" select="@name"/>
							<xsl:for-each select="//SMLCL:Alias[@name=$name] | //SMLCL:StateVariable[@name=$name]">
								<xsl:value-of select="dimension"/>
							</xsl:for-each>
							<!---->\" type=\"double\"/&gt;\n",i);
						}
					}
				} else {
					fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogAll size=\"%d\" headings=\"<xsl:value-of select="@name"/>\" type=\"double\" dims=\"<!---->
					<xsl:for-each select="//SMLCL:Alias[@name=$name] | //SMLCL:StateVariable[@name=$name]">
						<xsl:value-of select="dimension"/>
					</xsl:for-each>
					<!---->\"/&gt;\n",numEl_BRAHMS);
				}
				fprintf(<xsl:value-of select="@name"/>LOGREPORT,"		&lt;TimeStep dt=\"%f\"/&gt;\n", dt);
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "	&lt;/AnalogLog&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "&lt;/LogReport&gt;\n");
				
				fclose(<xsl:value-of select="@name"/>LOGREPORT);
				fclose(<xsl:value-of select="@name"/>LOGFILE);
			}
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="createAnalogSendPorts">
			<xsl:choose>
      <xsl:when test="@post">
        <!-- Handle non-postsynaptic output-->
				PORT<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORT<xsl:value-of select="@name"/>.create(hComponent);
				PORT<xsl:value-of select="@name"/>.setStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numConn_BRAHMS).cdims());
      </xsl:when>
      <xsl:otherwise>
				PORT<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORT<xsl:value-of select="@name"/>.create(hComponent);
				PORT<xsl:value-of select="@name"/>.setStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElements_BRAHMS).cdims());
			</xsl:otherwise>
			</xsl:choose>
</xsl:template>

<xsl:template match="SMLCL:AnalogReceivePort" mode="createAnalogRecvPorts">
				PORT<xsl:value-of select="@name"/>.attach(hComponent, "<xsl:value-of select="@name"/>");
				PORT<xsl:value-of select="@name"/>.validateStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElements_BRAHMS).cdims());
</xsl:template>

<xsl:template match="SMLCL:AnalogReducePort" mode="createAnalogReducePorts">
				set_BRAHMS = iif.getSet("<xsl:value-of select="@name"/>");
				numInputs_BRAHMS = iif.getNumberOfPorts(set_BRAHMS);
				PORT<xsl:value-of select="@name"/>.resize(numInputs_BRAHMS);
				<xsl:value-of select="@name"/>.resize(numElements_BRAHMS,0);
				for (int i_BRAHMS = 0; i_BRAHMS &lt; numInputs_BRAHMS; ++i_BRAHMS) {
					PORT<xsl:value-of select="@name"/>[i_BRAHMS].selectSet(set_BRAHMS);
					PORT<xsl:value-of select="@name"/>[i_BRAHMS].attach(hComponent, i_BRAHMS);
					PORT<xsl:value-of select="@name"/>[i_BRAHMS].validateStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElements_BRAHMS).cdims());
				}

</xsl:template>
    
<xsl:template match="SMLCL:AnalogReducePort" mode="createAnalogReducePortsRemap">
        set_BRAHMS = iif.getSet("<xsl:value-of select="@name"/>");
        numInputs_BRAHMS = iif.getNumberOfPorts(set_BRAHMS);
        <xsl:choose>
        <xsl:when test="@post">
        <!-- Handle postsynaptic input-->
        PORT<xsl:value-of select="@name"/>.resize(numInputs_BRAHMS);
        <xsl:value-of select="@name"/>.reserve(numConn_BRAHMS);
        for (int i_BRAHMS = 0; i_BRAHMS &lt; numInputs_BRAHMS; ++i_BRAHMS) {
        PORT<xsl:value-of select="@name"/>[i_BRAHMS].selectSet(set_BRAHMS);
        PORT<xsl:value-of select="@name"/>[i_BRAHMS].attach(hComponent, i_BRAHMS);
        PORT<xsl:value-of select="@name"/>[i_BRAHMS].validateStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElements_BRAHMS).cdims());
        }
        </xsl:when>
        <xsl:otherwise>
        PORT<xsl:value-of select="@name"/>.resize(numInputs_BRAHMS);
        <xsl:value-of select="@name"/>.reserve(numConn_BRAHMS);
        for (int i_BRAHMS = 0; i_BRAHMS &lt; numInputs_BRAHMS; ++i_BRAHMS) {
        PORT<xsl:value-of select="@name"/>[i_BRAHMS].selectSet(set_BRAHMS);
        PORT<xsl:value-of select="@name"/>[i_BRAHMS].attach(hComponent, i_BRAHMS);
        PORT<xsl:value-of select="@name"/>[i_BRAHMS].validateStructure(TYPE_REAL | TYPE_DOUBLE, Dims(numElementsIn_BRAHMS).cdims());
        }
        </xsl:otherwise>
        </xsl:choose>
        
</xsl:template>

<xsl:template match="SMLCL:AnalogReceivePort" mode="serviceAnalogPorts">
			<xsl:value-of select="@name"/>.resize(numElements_BRAHMS);
			memcpy(&amp;<xsl:value-of select="@name"/>[0], PORT<xsl:value-of select="@name"/>.getContent(), numElements_BRAHMS*sizeof(DOUBLE));
</xsl:template>
<xsl:template match="SMLCL:AnalogReducePort" mode="serviceAnalogPorts">
		DOUBLE* DATA<xsl:value-of select="@name"/>;
			for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
				DATA<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent();
				for (int j_BRAHMS = 0; j_BRAHMS &lt; <xsl:value-of select="@name"/>.size(); ++j_BRAHMS) {
					// reset value then sum inputs
					if (i_BRAHMS == 0) <xsl:value-of select="@name"/>[j_BRAHMS] = 0;
					<xsl:value-of select="@name"/>[j_BRAHMS] += DATA<xsl:value-of select="@name"/>[j_BRAHMS];
				}
			}
			<!---->
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="serviceAnalogPorts">
<!-- blank for now -->
</xsl:template>

<xsl:template match="SMLCL:AnalogReceivePort" mode="serviceAnalogPortsRemap">
	<!-- -->DOUBLE * TEMP<xsl:value-of select="@name"/>;
	        <xsl:value-of select="@name"/>.clear();
            <xsl:value-of select="@name"/>.resize(numConn_BRAHMS,0);
			TEMP<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>.getContent();
			for (int i_BRAHMS = 0; i_BRAHMS &lt; connectivityS2C.size(); ++i_BRAHMS) {
				for (int j_BRAHMS = 0; j_BRAHMS &lt; connectivityS2C[i_BRAHMS].size(); ++j_BRAHMS) {
					<xsl:value-of select="@name"/>[connectivityS2C[i_BRAHMS][j_BRAHMS]] = TEMP<xsl:value-of select="@name"/>[i_BRAHMS];
				}
			}
</xsl:template>

<xsl:template match="SMLCL:AnalogReducePort" mode="serviceAnalogPortsRemap">
     <xsl:choose>
     <xsl:when test="@post">
     <!-- Handle postsynaptic input-->
     
     		DOUBLE* DATA<xsl:value-of select="@name"/>;
        <xsl:value-of select="@name"/>.clear();
      	<xsl:value-of select="@name"/>.resize(numConn_BRAHMS,0);
				for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
					DATA<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent();				
					for (int j_BRAHMS = 0; j_BRAHMS &lt; connectivityD2C.size(); ++j_BRAHMS) {
						// sum inputs
						for (int k_BRAHMS = 0; k_BRAHMS &lt; connectivityD2C[j_BRAHMS].size(); ++k_BRAHMS) {
							<xsl:value-of select="@name"/>[connectivityD2C[j_BRAHMS][k_BRAHMS]] += DATA<xsl:value-of select="@name"/>[j_BRAHMS];
						}
					}
				}
     
     </xsl:when>
     <xsl:otherwise>

			DOUBLE* DATA<xsl:value-of select="@name"/>;
            if (!delayedAnalogVals.size()) {
            	<xsl:value-of select="@name"/>.clear();
            	<xsl:value-of select="@name"/>.resize(numConn_BRAHMS,0);
				for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
					DATA<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent();				
					for (int j_BRAHMS = 0; j_BRAHMS &lt; connectivityS2C.size(); ++j_BRAHMS) {
						// sum inputs
						for (int k_BRAHMS = 0; k_BRAHMS &lt; connectivityS2C[j_BRAHMS].size(); ++k_BRAHMS) {
							<xsl:value-of select="@name"/>[connectivityS2C[j_BRAHMS][k_BRAHMS]] += DATA<xsl:value-of select="@name"/>[j_BRAHMS];
						}
					}
				}
			} else {
				for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
					DATA<xsl:value-of select="@name"/> = (DOUBLE*) PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent();	
					for (int j_BRAHMS = 0; j_BRAHMS &lt; connectivityS2C.size(); ++j_BRAHMS) {
						// sum inputs into buffer
						for (int k_BRAHMS = 0; k_BRAHMS &lt; connectivityS2C[j_BRAHMS].size(); ++k_BRAHMS) {
							int delayBufferCurr_BRAHMS = (delayBufferIndex+delayForConn[connectivityS2C[j_BRAHMS][k_BRAHMS]])%delayBuffer.size();
							if (!delayedAnalogVals[delayBufferCurr_BRAHMS].size()) {
								delayedAnalogVals[delayBufferCurr_BRAHMS].resize(numConn_BRAHMS,0);
							}
							delayedAnalogVals[delayBufferCurr_BRAHMS][connectivityS2C[j_BRAHMS][k_BRAHMS]] += DATA<xsl:value-of select="@name"/>[j_BRAHMS];
						}
					}
				}
				// copy from buffer
				<xsl:value-of select="@name"/> = delayedAnalogVals[delayBufferIndex];
				delayedAnalogVals[delayBufferIndex].clear();
				delayedAnalogVals[delayBufferIndex].resize(numConn_BRAHMS,0);
				// initialisation
				if (!<xsl:value-of select="@name"/>.size()) {
					<xsl:value-of select="@name"/>.resize(numConn_BRAHMS,0);
				}
			}
			
			</xsl:otherwise>
			</xsl:choose>
			
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="outputAnalogPorts">
			PORT<xsl:value-of select="@name"/>.setContent(&amp;<xsl:value-of select="@name"/>[0]);
</xsl:template>

<xsl:template match="SMLCL:AnalogSendPort" mode="outputAnalogPortsRemap">
			<xsl:choose>
      <xsl:when test="@post">
        <!-- Handle non-postsynaptic output-->
				PORT<xsl:value-of select="@name"/>.setContent(&amp;<xsl:value-of select="@name"/>[0]);
      </xsl:when>
      <xsl:otherwise>
			vector &lt; DOUBLE &gt; OUT<xsl:value-of select="@name"/>;
			OUT<xsl:value-of select="@name"/>.resize(numElements_BRAHMS, 0);
			for (int i_BRAHMS = 0; i_BRAHMS &lt; numEl_BRAHMS; ++i_BRAHMS) {

				OUT<xsl:value-of select="@name"/>[connectivityC2D[i_BRAHMS]] += <xsl:value-of select="@name"/>[i_BRAHMS];
			}	

			PORT<xsl:value-of select="@name"/>.setContent(&amp;OUT<xsl:value-of select="@name"/>[0]);
			</xsl:otherwise>
			</xsl:choose>
</xsl:template>

</xsl:stylesheet>
