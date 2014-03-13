<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer"
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLLOWNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!-- START TEMPLATE -->
<xsl:template name="networkLayerNeurons">

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- ENTER THE EXPERIMENT FILE -->
<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
<xsl:variable name="main_root" select="/"/>


<!-- OLD CODE BELOW - COMMENTING MAY BE SPORADIC -->

<xsl:for-each select="/SMLLOWNL:SpineML/SMLLOWNL:Population">
<xsl:variable name="curr_pop" select="."/>
<!-- IGNORE SpikeSource -->
<xsl:if test="not(SMLLOWNL:Neuron/@url='SpikeSource')">
<Process>
        <xsl:variable name="linked_file" select="document(SMLLOWNL:Neuron/@url)"/>
        <Name><xsl:value-of select="translate(SMLLOWNL:Neuron/@name,' -', '_H')"/></Name>
        <Class>dev/SpineML/temp/NB/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/></Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
        <xsl:attribute name="a">size;<!---->
        <!-- PROPERTIES -->
        <xsl:for-each select="SMLLOWNL:Neuron/SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_pop/SMLLOWNL:Neuron/@name]/SMLNL:Property">
        	<xsl:value-of select="@name"/>
        	<xsl:if test="count(.//SMLNL:UniformDistribution)>0 or count(.//SMLNL:NormalDistribution)>0">
        		<!---->RANDX<!---->
        	</xsl:if>
	    	<xsl:if test="local-name(..)='Configuration'">
			<!---->OVER2<!---->
	    	</xsl:if>
        	<!---->;<!---->
        	<xsl:if test="count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=1 and count(.//SMLNL:ValueList)=1">
		    	<xsl:value-of select="@name"/>
		    	<!---->OVER1<!---->
		    	<!---->;<!---->
        	</xsl:if>
        </xsl:for-each>
        <!-- LOGS -->
        <xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@tcp_port) and @target=$curr_pop/SMLLOWNL:Neuron/@name]">
        	<xsl:value-of select="concat(@port,'LOG')"/>
        	<!---->;<!---->
        </xsl:for-each>
        <!-- A FILENAME FOR LOGGING -->
        <!---->logfileNameForComponent;<!---->
        </xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
        <m c="f"><xsl:value-of select="SMLLOWNL:Neuron/@size"/></m>
        <xsl:for-each select="SMLLOWNL:Neuron//SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_pop/SMLLOWNL:Neuron/@name]/SMLNL:Property">
        
        <!-- NO VALUE -->
        <xsl:if test="count(.//*)=0">
        	<m c="f">
        	<xsl:value-of select="'0'"/>
        	</m>
        </xsl:if>
        <!-- FIXED VALUE -->
        <xsl:if test="count(.//SMLNL:FixedValue)>0">
        	<m c="f">
        	<xsl:value-of select=".//SMLNL:FixedValue/@value"/>
        	</m>
        </xsl:if>
        <!-- STOCHASTIC VALUE (NORMAL) -->
        <xsl:if test="count(.//SMLNL:NormalDistribution)>0">
		    <m b="1 4" c="f">
		    <!---->1 <!---->
		    <xsl:value-of select=".//SMLNL:NormalDistribution/@mean"/>
		    <xsl:text> </xsl:text>
		    <xsl:value-of select=".//SMLNL:NormalDistribution/@variance"/>
		    <xsl:text> </xsl:text>
		    <xsl:value-of select=".//SMLNL:NormalDistribution/@seed"/>
		    </m>
	    </xsl:if>
	    <!-- STOCHASTIC VALUE (UNIFORM) -->
	    <xsl:if test="count(.//SMLNL:UniformDistribution)>0">
			<m b="1 4" c="f">
			<!---->2 <!---->
			<xsl:value-of select=".//SMLNL:UniformDistribution/@minimum"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select=".//SMLNL:UniformDistribution/@maximum"/>
			<xsl:text> </xsl:text>
		    	<xsl:value-of select=".//SMLNL:UniformDistribution/@seed"/>
			</m>
		</xsl:if>
		<!-- VALUE LIST -->
		<xsl:if test="count(.//SMLNL:ValueList)=1 and count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=0">
			<m><xsl:attribute name="b">
			<xsl:choose>
				<xsl:when test="local-name(..)='Configuration' and count(../SMLNL:Value) &lt; number($curr_pop/SMLLOWNL:Neuron/@size)">
				<!---->2 <!---->
				</xsl:when>
				<xsl:otherwise>
				<!---->1 <!---->
				</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="count(.//SMLNL:Value)"/>
			</xsl:attribute>
			<xsl:attribute name="c">
			<!---->f<!---->
			</xsl:attribute>
			<xsl:for-each select=".//SMLNL:Value">
				<xsl:if test="local-name(../../..)='Configuration'">
				<xsl:value-of select="@index"/>
				<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="@value"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
			</m>
		</xsl:if>
		<!-- VALUE LIST AND OTHER -->
		<xsl:if test="count(.//SMLNL:ValueList)=1 and count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=1">
			<m><xsl:attribute name="b">
			<!---->2 <!---->
			<xsl:value-of select="count(.//SMLNL:Value)"/>
			</xsl:attribute>
			<xsl:attribute name="c">
			<!---->f<!---->
			</xsl:attribute>
			<xsl:for-each select=".//SMLNL:Value">
				<xsl:value-of select="@index"/>
				<xsl:text> </xsl:text>			
				<xsl:value-of select="@value"/>
				<xsl:text> </xsl:text>
			</xsl:for-each>
			</m>
		</xsl:if>
	
        </xsl:for-each>
        <!-- LOGS, WHERE NOT LOGGING 'ALL' -->
        <xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@tcp_port) and @indices and @target=$curr_pop/SMLLOWNL:Neuron/@name]">
			<m><xsl:attribute name="b">1 <!---->
        		<xsl:call-template name="count_array_items">
        			<xsl:with-param name="items" select="@indices"/>
        		</xsl:call-template>
        	</xsl:attribute>
        	<xsl:attribute name="c">f</xsl:attribute>
			<xsl:value-of select="translate(@indices,',',' ')"/>
        	</m>
        </xsl:for-each>
        <xsl:for-each select="$expt_root//SMLEXPT:LogOutput[not(@tcp_port) and not(@indices) and @target=$curr_pop/SMLLOWNL:Neuron/@name]">
			<m><xsl:attribute name="b">1 1<!---->
        	</xsl:attribute>
        	<xsl:attribute name="c">f</xsl:attribute>
			<!---->-1<!---->
        	</m>
        </xsl:for-each>
        <!-- NAME FOR USE IN LOGS -->
        <m><xsl:value-of select="translate(SMLLOWNL:Neuron/@name,' ', '_')"/></m>
	</State>
</Process>
</xsl:if>
</xsl:for-each>



<!-- EXIT THE EXPERIMENT FILE -->
</xsl:for-each>

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>

