<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="defineImpulsePorts">
	vector &lt; spikes::Input &gt; PORT<xsl:value-of select="@name"/>;
	vector &lt; DOUBLE &gt; <xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="defineImpulsePorts">
	spikes::Output PORTOut<xsl:value-of select="@name"/>;
	// Logging data structures for PORTOut<xsl:value-of select="@name"/>:
	vector &lt; float &gt; <xsl:value-of select="@name"/>LOGT; // The time of the impulse
	vector &lt; int &gt; <xsl:value-of select="@name"/>LOGVAR; // Neuron/connection index of the impulse
	vector &lt; DOUBLE &gt; <xsl:value-of select="@name"/>LOGVALUE; // The value of the impulse
	vector &lt; int &gt; <xsl:value-of select="@name"/>LOGMAP; // This is a list of the indices to log, if "all" are not to be logged.
	FILE * <xsl:value-of select="@name"/>LOGFILE;
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="resizeReceive">
			// template match="SMLCL:ImpulseReceivePort" mode="resizeReceive"
			<xsl:value-of select="@name"/>.resize(numEl_BRAHMS,0);
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPorts">
				// template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPorts"
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numElements_BRAHMS*60);
</xsl:template>


<xsl:template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPortsWU">
				// template match="SMLCL:ImpulseSendPort" mode="createImpulseSendPortsWU"
				PORTOut<xsl:value-of select="@name"/>.setName("<xsl:value-of select="@name"/>");
				PORTOut<xsl:value-of select="@name"/>.create(hComponent);
				PORTOut<xsl:value-of select="@name"/>.setCapacity(numConn_BRAHMS*60);
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="createImpulseRecvPorts">
				// template match="SMLCL:ImpulseReceivePort" mode="createImpulseRecvPorts"
				set_BRAHMS = iif.getSet("<xsl:value-of select="@name"/>");
				numInputs_BRAHMS = iif.getNumberOfPorts(set_BRAHMS);
				PORT<xsl:value-of select="@name"/>.resize(numInputs_BRAHMS);
				for (int i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; numInputs_BRAHMS; ++i_BRAHMS_LOOP) {
					PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].selectSet(set_BRAHMS);
					PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].attach(hComponent, i_BRAHMS_LOOP);

				}

</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePorts">
			// template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePorts"
			vector &lt; INT32* &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i_BRAHMS = 0; i_BRAHMS &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS] = PORT<xsl:value-of select="@name"/>[i_BRAHMS].getContent(DATA<xsl:value-of select="@name"/>[i_BRAHMS]);
			}
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="serviceImpulsePorts">
			// template match="SMLCL:ImpulseSendPort" mode="serviceImpulsePorts"
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; INT32 &gt; DATAOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePortsRemap">
			// template match="SMLCL:ImpulseReceivePort" mode="serviceImpulsePortsRemap"
			<xsl:choose>
			<xsl:when test="@post">
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; INT32 &gt; &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; DOUBLE &gt; &gt; DATAval<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			DATAval<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS_LOOP) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP] = PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].getContent(TEMP<xsl:value-of select="@name"/>);
				// service Impulses port
				for (int j_BRAHMS_LOOP = 0; j_BRAHMS_LOOP &lt; COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP]; j_BRAHMS_LOOP+=3 /* one int + one double = 3 int */) {
					// extract the values
					INT32 impulseIndex__In;
					DOUBLE impulseValue__In;
					getImpulse(TEMP<xsl:value-of select="@name"/>, j_BRAHMS_LOOP, impulseIndex__In, impulseValue__In);
					// remap the input
					for (int k_BRAHMS_LOOP = 0; k_BRAHMS_LOOP &lt; connectivityD2C[impulseIndex__In].size(); ++k_BRAHMS_LOOP) {
						// add the index from the lookup
						DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(connectivityD2C[impulseIndex__In][k_BRAHMS_LOOP]);
						// add the value
						DATAval<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(impulseValue__In);
					}
				}
			}
			</xsl:when>
			<xsl:otherwise>
			INT32* TEMP<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; INT32 &gt; &gt; DATA<xsl:value-of select="@name"/>;
			vector &lt; vector &lt; DOUBLE &gt; &gt; DATAval<xsl:value-of select="@name"/>;
			vector &lt; UINT32 &gt; COUNT<xsl:value-of select="@name"/>;
			DATA<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			DATAval<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			COUNT<xsl:value-of select="@name"/>.resize(PORT<xsl:value-of select="@name"/>.size());
			for (int i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; PORT<xsl:value-of select="@name"/>.size(); ++i_BRAHMS_LOOP) {
				COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP] = PORT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].getContent(TEMP<xsl:value-of select="@name"/>);
				// service Impulses port
				for (int j_BRAHMS_LOOP = 0; j_BRAHMS_LOOP &lt; COUNT<xsl:value-of select="@name"/>[i_BRAHMS_LOOP]; j_BRAHMS_LOOP+=3 /* one int + one double = 3 int */) {
					// extract the values
					INT32 impulseIndex__In;
					DOUBLE impulseValue__In;
					getImpulse(TEMP<xsl:value-of select="@name"/>, j_BRAHMS_LOOP, impulseIndex__In, impulseValue__In);
					// remap the input
					for (int k_BRAHMS_LOOP = 0; k_BRAHMS_LOOP &lt; connectivityS2C[impulseIndex__In].size(); ++k_BRAHMS_LOOP) {
						// add the index from the lookup
						DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(connectivityS2C[impulseIndex__In][k_BRAHMS_LOOP]);
						// add the value
						DATAval<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].push_back(impulseValue__In);
					}
				}
			}

			// do delay
			if (delayBuffer.size()) {
				// for each spike
				for (UINT32 i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; DATA<xsl:value-of select="@name"/>.size(); ++i_BRAHMS_LOOP) {
					for (UINT32 j_BRAHMS_LOOP = 0; j_BRAHMS_LOOP &lt; DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP].size(); ++j_BRAHMS_LOOP) {

						// get delay buffer index to set and add impulse to buffer lists
						delayBuffer[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]])%delayBuffer.size()].push_back(DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]);
						delayedImpulseVals[(delayBufferIndex+delayForConn[DATA<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]])%delayBuffer.size()].push_back(DATAval<xsl:value-of select="@name"/>[i_BRAHMS_LOOP][j_BRAHMS_LOOP]);

					}
				}
			}
			</xsl:otherwise>
			</xsl:choose>
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="serviceImpulsePortsRemap">
			// template match="SMLCL:ImpulseSendPort" mode="serviceImpulsePortsRemap"
			INT32* TEMP<xsl:value-of select="@name"/>;
			// Though impulse value is a double, the index, and the double are stored in a vector of INT32s:
			vector &lt; INT32 &gt; DATAOut<xsl:value-of select="@name"/>;
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="outputImpulsePorts">
			// template match="SMLCL:ImpulseSendPort" mode="outputImpulsePorts"
			PORTOut<xsl:value-of select="@name"/>.setContent(&amp;DATAOut<xsl:value-of select="@name"/>[0], DATAOut<xsl:value-of select="@name"/>.size());
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="outputImpulsePortsRemap">
			// template match="SMLCL:ImpulseSendPort" mode="outputImpulsePortsRemap"
			vector &lt; INT32 &gt; OUT<xsl:value-of select="@name"/>;
			for (INT32 i_BRAHMS_LOOP = 0; i_BRAHMS_LOOP &lt; DATAOut<xsl:value-of select="@name"/>.size(); i_BRAHMS_LOOP+=3) {
				INT32 impulseIndex__Out;
				DOUBLE impulseValue__Out;
				getImpulse(&amp;(DATAOut<xsl:value-of select="@name"/>[0]), i_BRAHMS_LOOP, impulseIndex__Out, impulseValue__Out);
				// add the remapped impulse to the output
				addImpulse(OUT<xsl:value-of select="@name"/>, connectivityC2D[impulseIndex__Out], impulseValue__Out);
			}
			PORTOut<xsl:value-of select="@name"/>.setContent(&amp;OUT<xsl:value-of select="@name"/>[0], OUT<xsl:value-of select="@name"/>.size());
</xsl:template>

<!--
    Now the logging templates
-->
<xsl:template match="SMLCL:ImpulseSendPort" mode="createSendPortLogs">
			// template match="SMLCL:ImpulseSendPort" mode="createSendPortLogs"
			// check for existence of log stateNode FOR IMPULSE LOGS
			if (nodeState.hasField("<xsl:value-of select="@name"/>LOG")) {
				// we have a log! Read the data in:
				VDOUBLE tempLogData_BRAHMS = nodeState.getField("<xsl:value-of select="@name"/>LOG").getArrayDOUBLE();
				if (tempLogData_BRAHMS.size() == 0) berr &lt;&lt; "ERROR: log with no indices";
				// if we are logging 'all'
				if (tempLogData_BRAHMS[0] &lt; -0.1) {
					<xsl:value-of select="@name"/>LOGMAP.push_back(-2);
				} else {
					// otherwise resize the logmap:
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

<xsl:template match="SMLCL:ImpulseSendPort" mode="makeSendPortLogs">
				// template match="SMLCL:ImpulseSendPort" mode="makeSendPortLogs"
				if (<xsl:value-of select="@name"/>LOGMAP.size() &gt; 0) {
					// DATAOut<xsl:value-of select="@name"/> contains INT32,DOUBLE,INT32,DOUBLE etc...
					DOUBLE d2_S2B; // Temporary variable used to copy data into <xsl:value-of select="@name"/>LOGVALUE
					DOUBLE* d2p_S2B = &amp;d2_S2B;
					for (unsigned int i_BRAHMS = 0; i_BRAHMS &lt; DATAOut<xsl:value-of select="@name"/>.size(); i_BRAHMS+=3) {
						// if LOGMAP[0] &lt; -1.1, then it's log "all"
						if (<xsl:value-of select="@name"/>LOGMAP[0] &lt; -1.1) {
							<xsl:value-of select="@name"/>LOGT.push_back(t);
							<xsl:value-of select="@name"/>LOGVAR.push_back(DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]);
							memcpy (d2p_S2B, &amp;(DATAOut<xsl:value-of select="@name"/>[i_BRAHMS+1]), 2*sizeof(INT32));
							<xsl:value-of select="@name"/>LOGVALUE.push_back(d2_S2B);
							}
						if (<xsl:value-of select="@name"/>LOGMAP.size() > DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]) {
							if (<xsl:value-of select="@name"/>LOGMAP[DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]]+1 &gt; 0) {
								berr &lt;&lt; "This code section in SpineML_ImpulsePort.xsl needs reviewing. LOGVALUE is not set here as it should be.";
								<xsl:value-of select="@name"/>LOGT.push_back((INT32)DATAOut<xsl:value-of select="@name"/>[i_BRAHMS]); // The first INT32.
								<xsl:value-of select="@name"/>LOGVAR.push_back((DOUBLE)DATAOut<xsl:value-of select="@name"/>[i_BRAHMS+1]);
							}
						}
					}
					if (<xsl:value-of select="@name"/>LOGVAR.size() &gt; 100000) {
						for (unsigned int i_BRAHMS = 0; i_BRAHMS &lt; <xsl:value-of select="@name"/>LOGVAR.size(); i_BRAHMS++) {
							fprintf(<xsl:value-of select="@name"/>LOGFILE, "%f, %d, %f\n", <xsl:value-of select="@name"/>LOGT[i_BRAHMS],<xsl:value-of select="@name"/>LOGVAR[i_BRAHMS],<xsl:value-of select="@name"/>LOGVALUE[i_BRAHMS]);
						}
						<xsl:value-of select="@name"/>LOGT.clear();
						<xsl:value-of select="@name"/>LOGVAR.clear();
						<xsl:value-of select="@name"/>LOGVALUE.clear();
					}
				}
</xsl:template>

<xsl:template match="SMLCL:ImpulseSendPort" mode="finaliseLogs">
			// template match="SMLCL:ImpulseSendPort" mode="finaliseLogs"
			if (<xsl:value-of select="@name"/>LOGMAP.size() &gt; 0) {
				for (unsigned int i_BRAHMS = 0; i_BRAHMS &lt; <xsl:value-of select="@name"/>LOGVAR.size(); i_BRAHMS++) {
					fprintf(<xsl:value-of select="@name"/>LOGFILE, "%f, %d, %f\n", <xsl:value-of select="@name"/>LOGT[i_BRAHMS],<xsl:value-of select="@name"/>LOGVAR[i_BRAHMS],<xsl:value-of select="@name"/>LOGVALUE[i_BRAHMS]);
				}
				<!-- WRITE XML FOR LOGS -->
				FILE * <xsl:value-of select="@name"/>LOGREPORT;
				string logFileName_BRAHMS = baseNameForLogs_BRAHMS;
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_logrep.xml");
				<xsl:value-of select="@name"/>LOGREPORT = fopen(logFileName_BRAHMS.c_str(),"w");
				logFileName_BRAHMS = baseNameForLogs_BRAHMS;
				logFileName_BRAHMS.append("_<xsl:value-of select="@name"/>_log.csv");
				unsigned found = logFileName_BRAHMS.find_last_of("/\\");
				logFileName_BRAHMS = logFileName_BRAHMS.substr(found+1);
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

</xsl:stylesheet>
