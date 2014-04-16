<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:EventReceivePort" mode="defineEventPorts">
vector &lt; spikes::Input &gt; PORT<xsl:value-of select="@name"/>;
</xsl:template>
<xsl:template match="SMLCL:EventSendPort" mode="defineEventPorts">
spikes::Output PORTOut<xsl:value-of select="@name"/>;
<!-- CREATE LOG VECTOR AND MAP AND FILE HANDLE -->
vector &lt; float &gt; <xsl:value-of select="@name"/>LOGT;
vector &lt; int &gt; <xsl:value-of select="@name"/>LOGVAR;
vector &lt; int &gt; <xsl:value-of select="@name"/>LOGMAP;
FILE * <xsl:value-of select="@name"/>LOGFILE;
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="createEventSendPorts">
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numElements_BRAHMS*20);
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="createSendPortLogs">
<!-- GET LOG INFO AND RESIZE LOG VECTOR -->
			// check for existence of log stateNode
			if (nodeState.hasField("<xsl:value-of select="@name"/>LOG")) {
				// we have a log! Read the data in:
				VDOUBLE tempLogData_BRAHMS = nodeState.getField("<xsl:value-of select="@name"/>LOG").getArrayDOUBLE();
				if (tempLogData_BRAHMS.size() == 0) berr &lt;&lt; "ERROR: log with no indices";
				// if we are logging 'all'
				if (tempLogData_BRAHMS[0] &lt; -0.1) {
					<xsl:value-of select="@name"/>LOGMAP.push_back(-2);
				} else {
				// otherwise
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
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_log.csv");
				<xsl:value-of select="@name"/>LOGFILE = fopen(logFileName_BRAHMS.c_str(),"w");
			}
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="makeSendPortLogs">
				if (<xsl:value-of select="@name"/>LOGMAP.size() &gt; 0) {
					for (unsigned int i_BRAHMS = 0; i_BRAHMS &lt; DATAOut<xsl:value-of select="@name"/>.size(); i_BRAHMS++) {
						if (<xsl:value-of select="@name"/>LOGMAP[0] &lt; -1.1) {
							<xsl:value-of select="@name"/>LOGT.push_back(t);
							<xsl:value-of select="@name"/>LOGVAR.push_back(DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]);
						}
						if (<xsl:value-of select="@name"/>LOGMAP.size() > DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]) {
							if (<xsl:value-of select="@name"/>LOGMAP[DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]]+1) {
								<xsl:value-of select="@name"/>LOGT.push_back(t);
								<xsl:value-of select="@name"/>LOGVAR.push_back(DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]);
							}
						} 
					}
					if (<xsl:value-of select="@name"/>LOGVAR.size() &gt; 100000) {
						for (unsigned int i_BRAHMS = 0; i_BRAHMS &lt; <xsl:value-of select="@name"/>LOGVAR.size(); i_BRAHMS++) {
							fprintf(<xsl:value-of select="@name"/>LOGFILE, "%f, %d\n", <xsl:value-of select="@name"/>LOGT[i_BRAHMS],<xsl:value-of select="@name"/>LOGVAR[i_BRAHMS]);
						}
						<xsl:value-of select="@name"/>LOGT.clear();
						<xsl:value-of select="@name"/>LOGVAR.clear();
					}
				}
</xsl:template>

<xsl:template match="SMLCL:EventSendPort" mode="finaliseLogs">
			if (<xsl:value-of select="@name"/>LOGMAP.size() &gt; 0) {
				for (unsigned int i_BRAHMS = 0; i_BRAHMS &lt; <xsl:value-of select="@name"/>LOGVAR.size(); i_BRAHMS++) {
					fprintf(<xsl:value-of select="@name"/>LOGFILE, "%f, %d\n", <xsl:value-of select="@name"/>LOGT[i_BRAHMS],<xsl:value-of select="@name"/>LOGVAR[i_BRAHMS]);
				}
				<!-- WRITE XML FOR LOGS -->
				FILE * <xsl:value-of select="@name"/>LOGREPORT;
				string logFileName_BRAHMS = baseNameForLogs_BRAHMS;
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_logrep.xml");
				<xsl:value-of select="@name"/>LOGREPORT = fopen(logFileName_BRAHMS.c_str(),"w");
				logFileName_BRAHMS = baseNameForLogs_BRAHMS;
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_log.csv");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "&lt;LogReport&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "	&lt;EventLog&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogFile&gt;%s&lt;/LogFile&gt;\n",logFileName_BRAHMS.c_str());
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogFileType&gt;csv&lt;/LogFileType&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogPort&gt;<xsl:value-of select="@name"/>&lt;/LogPort&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogEndTime&gt;%f&lt;/LogEndTime&gt;\n",t);
				if (<xsl:value-of select="@name"/>LOGMAP[0] &gt; -1.1) {
					for (unsigned int i = 0; i &lt; <xsl:value-of select="@name"/>LOGMAP.size(); ++i) {
						if (<xsl:value-of select="@name"/>LOGMAP[i] &gt; -0.1) {
							fprintf(<xsl:value-of select="@name"/>LOGREPORT,"		&lt;LogIndex&gt;%d&lt;/LogIndex&gt;\n",i);
						}
					}
				} else {
					fprintf(<xsl:value-of select="@name"/>LOGREPORT, "		&lt;LogAll size=\"%d\" type=\"int\" dims=\"<!---->
					<xsl:variable name="name" select="@name"/>
					<xsl:for-each select="//SMLCL:Alias[@name=$name] | //SMLCL:StateVariable[@name=$name]">
						<xsl:value-of select="dimension"/>
					</xsl:for-each>
					<!---->\"/&gt;\n",numEl_BRAHMS);
				}
				fprintf(<xsl:value-of select="@name"/>LOGREPORT,"		&lt;LogCol heading=\"t\" dims=\"ms\" type=\"double\"/&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT,"		&lt;LogCol heading=\"index\" dims=\"\" type=\"int\"/&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT,"		&lt;TimeStep dt=\"%f\"/&gt;\n", dt);
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "	&lt;/EventLog&gt;\n");
				fprintf(<xsl:value-of select="@name"/>LOGREPORT, "&lt;/LogReport&gt;\n");
				
				fclose(<xsl:value-of select="@name"/>LOGREPORT);
				fclose(<xsl:value-of select="@name"/>LOGFILE);
			}
</xsl:template>			

<xsl:template match="SMLCL:EventReceivePort" mode="createEventRecvPorts">
				set_BRAHMS = iif.getSet("<xsl:value-of select="@name"/>");
				numInputs_BRAHMS = iif.getNumberOfPorts(set_BRAHMS);
				PORT<xsl:value-of select="@name"/>.resize(numInputs_BRAHMS);
				for (int i_BRAHMS = 0; i_BRAHMS &lt; numInputs_BRAHMS; ++i_BRAHMS) {
					PORT<xsl:value-of select="@name"/>[i_BRAHMS].selectSet(set_BRAHMS);
					PORT<xsl:value-of select="@name"/>[i_BRAHMS].attach(hComponent, i_BRAHMS);
					
				}
</xsl:template>

<xsl:template match="SMLCL:EventReceivePort" mode="serviceEventPorts">
			vector &lt; INT32* &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS] = PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent(DATA<xsl:value-of select="@name"/>[i_BRAHMS]);
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
			for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS] = PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent(TEMP<xsl:value-of select="@name"/>);
				// service events port
				for (int j_BRAHMS = 0; j_BRAHMS &lt; COUNT<xsl:value-of select="@name"/>[i_BRAHMS]; ++j_BRAHMS) {
					// remap the input
					if (TEMP<xsl:value-of select="@name"/>[j_BRAHMS] &gt; connectivityS2C.size()-1) berr &lt;&lt; "Out of range, value = " &lt;&lt; float(TEMP<xsl:value-of select="@name"/>[j_BRAHMS]);
					for (int k_BRAHMS = 0; k_BRAHMS &lt; connectivityS2C[TEMP<xsl:value-of select="@name"/>[j_BRAHMS]].size(); ++k_BRAHMS) {
						DATA<xsl:value-of select="@name"/>[i_BRAHMS].push_back(connectivityS2C[TEMP<xsl:value-of select="@name"/>[j_BRAHMS]][k_BRAHMS]);						
					}
				}
			}
			
			// do delay
			if (delayBuffer.size()) {
				// for each spike
				for (UINT32 i_BRAHMS = 0; i_BRAHMS &lt; DATA<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
					for (UINT32 j_BRAHMS = 0; j_BRAHMS &lt; DATA<xsl:value-of select="@name"/>[i_BRAHMS].size(); ++j_BRAHMS) {
				
						// get delay buffer index to set and add spike to buffer
						delayBuffer[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i_BRAHMS][j_BRAHMS]])%delayBuffer.size()].push_back(DATA<xsl:value-of select="@name"/>[i_BRAHMS][j_BRAHMS]);
				
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
			for (int i_BRAHMS = 0; i_BRAHMS &lt; DATAOut<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {

				OUT<xsl:value-of select="@name"/>.push_back(connectivityC2D[DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]]);

			}	
			PORTOut<xsl:value-of select="@name"/>.setContent(&amp;OUT<xsl:value-of select="@name"/>[0], OUT<xsl:value-of select="@name"/>.size());
</xsl:template>

</xsl:stylesheet>
