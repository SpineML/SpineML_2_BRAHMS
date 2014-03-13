<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 

xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer"
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEXPT="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="SMLNL SMLNL SMLCL SMLEXPT fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>
<!--

Ok, here we attempt to get a user layer description into giving us a systemML description...

-->

<xsl:template name="count_array_items">
<xsl:param name="items"/>
<xsl:param name="count" select="1"/>
<xsl:choose>
<xsl:when test="contains($items, ',')">
<xsl:variable name="item" select="substring-before($items,',')"/>
<xsl:variable name="remaining_items" select="substring-after($items,',')"/>
<xsl:call-template name="count_array_items">
	<xsl:with-param name="items" select="$remaining_items"/>
	<xsl:with-param name="count" select="$count + 1"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$count"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template match="/">

<xsl:variable name="expt_root" select="/"/>
<xsl:for-each select="document(//SMLEXPT:Model/@network_layer_url)">

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<System Version="1.0" AuthTool="SpineML to BRAHMS XSLT translator" AuthToolVersion="0">
<xsl:variable name="main_root" select="/"/>


<xsl:for-each select="/SMLNL:SpineML/SMLNL:Population">
<xsl:variable name="curr_pop" select="."/>
<!-- IGNORE SpikeSource -->
<xsl:if test="not(SMLNL:Neuron/@url='SpikeSource.xml')">
<Process>
        <xsl:variable name="linked_file" select="document(SMLNL:Neuron/@url)"/>
        <Name><xsl:value-of select="translate(SMLNL:Neuron/@name,' -', '_H')"/></Name>
        <Class>dev/SpineML/temp/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/></Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
        <xsl:attribute name="a">size;<!---->
        <xsl:for-each select="SMLNL:Neuron/SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_pop/SMLNL:Neuron/@name]/SMLNL:Property">
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
        </xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
        <m c="f"><xsl:value-of select="SMLNL:Neuron/@size"/></m>
        <xsl:for-each select="SMLNL:Neuron//SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_pop/SMLNL:Neuron/@name]/SMLNL:Property">
        
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
		    <xsl:value-of select=".//SMLNL:NormalDistribution/@variance"/> 123<!---->
		    </m>
	    </xsl:if>
	    <!-- STOCHASTIC VALUE (UNIFORM) -->
	    <xsl:if test="count(.//SMLNL:UniformDistribution)>0">
			<m b="1 4" c="f">
			<!---->2 <!---->
			<xsl:value-of select=".//SMLNL:UniformDistribution/@minimum"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select=".//SMLNL:UniformDistribution/@maximum"/> 123<!---->
			</m>
		</xsl:if>
		<!-- VALUE LIST -->
		<xsl:if test="count(.//SMLNL:ValueList)=1 and count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=0">
			<m><xsl:attribute name="b">
			<xsl:choose>
				<xsl:when test="local-name(..)='Configuration' and count(../SMLNL:Value) &lt; number($curr_pop/SMLNL:Neuron/@size)">
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
	</State>
</Process>
</xsl:if>
</xsl:for-each>



<xsl:for-each select="//SMLNL:Synapse">

<xsl:variable name="curr_syn" select="SMLNL:WeightUpdate"/>
<xsl:variable name="target_name" select="../@dst_population"/>
<xsl:variable name="source_name" select="../../SMLNL:Neuron/@name"/>

<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

<xsl:variable name="sizeIn">
<xsl:for-each select="/SMLNL:SpineML/SMLNL:Population">
<xsl:if test="SMLNL:Neuron/@name=$source_name">
<xsl:value-of select="SMLNL:Neuron/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>

<xsl:variable name="sizeOut">
<xsl:for-each select="/SMLNL:SpineML/SMLNL:Population">
<xsl:if test="SMLNL:Neuron/@name=$target_name">
<xsl:value-of select="SMLNL:Neuron/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>
        <xsl:variable name="linked_file" select="document(SMLNL:WeightUpdate/@url)"/>
<Process>

        <Name><xsl:value-of select="translate(.//SMLNL:WeightUpdate/@name, ' -', '_H')"/></Name>
        <Class>dev/SpineML/temp/<xsl:value-of select="local-name(SMLNL:ConnectionList)"/><xsl:value-of select="local-name(SMLNL:FixedProbabilityConnection)"/><xsl:value-of select="local-name(SMLNL:AllToAllConnection)"/><xsl:value-of select="local-name(SMLNL:OneToOneConnection)"/><xsl:value-of select="translate(document(SMLNL:WeightUpdate/@url)//SMLCL:ComponentClass/@name,' -', 'oH')"/></Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
        <xsl:attribute name="a">sizeIn;sizeOut;<xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Connection)>0">src;dst;<xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Delay)=0">delayForConn;</xsl:if></xsl:if><xsl:if test="count(.//SMLNL:FixedProbabilityConnection)=1">probabilityValue;</xsl:if>
        <xsl:for-each select="SMLNL:WeightUpdate/SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_syn/@name]/SMLNL:Property">
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
        </xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeIn"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
        <xsl:if test="count(./SMLNL:ConnectionList)>0">
        <m><xsl:attribute name="b">1 <xsl:value-of select="count(./SMLNL:ConnectionList/SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
        <xsl:for-each select="./SMLNL:ConnectionList/SMLNL:Connection"><xsl:value-of select="@src_neuron"/><xsl:text> </xsl:text></xsl:for-each>
	</m>
        <m><xsl:attribute name="b">1 <xsl:value-of select="count(./SMLNL:ConnectionList/SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
        <xsl:for-each select="./SMLNL:ConnectionList/SMLNL:Connection"><xsl:value-of select="@dst_neuron"/><xsl:text> </xsl:text></xsl:for-each>
	</m>
        <xsl:if test="count(./SMLNL:ConnectionList/SMLNL:Delay)=0">
        <m><xsl:attribute name="b">1 <xsl:value-of select="count(./SMLNL:ConnectionList/SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
        <xsl:for-each select="./SMLNL:ConnectionList/SMLNL:Connection"><xsl:value-of select="@delay"/><xsl:text> </xsl:text></xsl:for-each>
	</m>
	</xsl:if>
	</xsl:if>
        <xsl:if test="count(./SMLNL:FixedProbabilityConnection)=1"><m c="f"><xsl:value-of select=".//SMLNL:FixedProbabilityConnection/@probability"/></m></xsl:if>
        <xsl:for-each select="SMLNL:WeightUpdate//SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_syn/@name]/SMLNL:Property">
        
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
		    <xsl:value-of select=".//SMLNL:NormalDistribution/@variance"/> 123<!---->
		    </m>
	    </xsl:if>
	    <!-- STOCHASTIC VALUE (UNIFORM) -->
	    <xsl:if test="count(.//SMLNL:UniformDistribution)>0">
			<m b="1 4" c="f">
			<!---->2 <!---->
			<xsl:value-of select=".//SMLNL:UniformDistribution/@minimum"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select=".//SMLNL:UniformDistribution/@maximum"/> 123<!---->
			</m>
		</xsl:if>
		<!-- VALUE LIST -->
		<xsl:if test="count(.//SMLNL:ValueList)=1 and count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=0">
			<m><xsl:attribute name="b">
			<xsl:choose>
				<xsl:when test="local-name(..)='Configuration' and count(../SMLNL:Value) &lt; number($sizeIn)">
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
				<!--xsl:if test="local-name(..)='Configuration' and count(../SMLNL:Value) &lt; number($sizeIn)"-->
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
        </State>
</Process>

</xsl:if>

</xsl:for-each>



<xsl:for-each select="//SMLNL:Synapse">

<xsl:variable name="curr_psp" select="SMLNL:PostSynapse"/>
<xsl:variable name="target_name" select="../@dst_population"/>
<xsl:variable name="source_name" select="../../SMLNL:Neuron/@name"/>

<!-- APPLY LESION -->
<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">
<!--       -->
<xsl:variable name="sizeOut">
<xsl:for-each select="/SMLNL:SpineML/SMLNL:Population">
<xsl:if test="SMLNL:Neuron/@name=$target_name">
<xsl:value-of select="SMLNL:Neuron/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>

        <xsl:variable name="linked_file" select="document(SMLNL:PostSynapse/@url)"/>
<Process>

        <Name><xsl:value-of select="translate(.//SMLNL:PostSynapse/@name, ' -', '_H')"/></Name>
        <Class>dev/SpineML/temp/<xsl:value-of select="translate($linked_file/SMLCL:SpineML/SMLCL:ComponentClass/@name,' -', 'oH')"/></Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
        <xsl:attribute name="a">size;<!---->
        <xsl:for-each select="SMLNL:PostSynapse/SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_psp/@name]/SMLNL:Property">
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
        </xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
        <xsl:for-each select="SMLNL:PostSynapse//SMLNL:Property | $expt_root//SMLEXPT:Experiment//SMLEXPT:Configuration[@target=$curr_psp/@name]/SMLNL:Property">
        
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
		    <xsl:value-of select=".//SMLNL:NormalDistribution/@variance"/> 123<!---->
		    </m>
	    </xsl:if>
	    <!-- STOCHASTIC VALUE (UNIFORM) -->
	    <xsl:if test="count(.//SMLNL:UniformDistribution)>0">
			<m b="1 4" c="f">
			<!---->2 <!---->
			<xsl:value-of select=".//SMLNL:UniformDistribution/@minimum"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select=".//SMLNL:UniformDistribution/@maximum"/> 123<!---->
			</m>
		</xsl:if>
		<!-- VALUE LIST -->
		<xsl:if test="count(.//SMLNL:ValueList)=1 and count(.//SMLNL:FixedValue | .//SMLNL:UniformDistribution | .//SMLNL:NormalDistribution)=0">
			<m><xsl:attribute name="b">
			<xsl:choose>
				<xsl:when test="local-name(..)='Configuration' and count(../SMLNL:Value) &lt; number($sizeOut)">
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
				<xsl:if test="local-name(../../..)='Configuration' and count(../SMLNL:Value) &lt; number($sizeOut)">
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
	</State>
</Process>

</xsl:if>

</xsl:for-each>

<!-- LINKS -->

<xsl:for-each select="//SMLNL:WeightUpdate">

<xsl:variable name="target_name" select="../../@dst_population"/>
<xsl:variable name="source_name" select="../../../SMLNL:Neuron/@name"/>

<!-- APPLY LESION -->
<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">
<xsl:if test="not(../../../SMLNL:Neuron/@url='SpikeSource.xml')">

<xsl:variable name="dstPortRef" select="@input_dst_port"/>
<Link>
        <Src><xsl:value-of select="translate(../../../SMLNL:Neuron/@name,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@input_src_port"/></Src>
        <Dst><xsl:value-of select="translate(@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@input_dst_port"/></Dst>
        <Lag><xsl:if test="count(../*/SMLNL:Delay/SMLNL:FixedValue)=1"><xsl:value-of select="number(../*/SMLNL:Delay/SMLNL:FixedValue/@value)*number(10)"/></xsl:if><xsl:if test="not(count(../*/SMLNL:Delay/SMLNL:FixedValue)=1)">1</xsl:if></Lag>
</Link>

</xsl:if>
</xsl:if>

</xsl:for-each>

<xsl:for-each select="//SMLNL:PostSynapse">

<xsl:variable name="target_name" select="../../@dst_population"/>
<xsl:variable name="source_name" select="../../../SMLNL:Neuron/@name"/>

<!-- APPLY LESION -->
<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

<xsl:variable name="dstPortRef" select="@input_dst_port"/>
<Link>
        <Src><xsl:value-of select="translate(../SMLNL:WeightUpdate/@name,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@input_src_port"/></Src>
        <Dst><xsl:value-of select="translate(@name,' -', '_H')"/><xsl:if test="count(document(@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1 or count(document(@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@input_dst_port"/></Dst>
	<Lag>0</Lag>
</Link>

</xsl:if>

</xsl:for-each>

<xsl:for-each select="//SMLNL:PostSynapse">

<xsl:variable name="target_name" select="../../@dst_population"/>
<xsl:variable name="source_name" select="../../../SMLNL:Neuron/@name"/>

<!-- APPLY LESION -->
<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

<xsl:variable name="dstPortRef" select="@output_dst_port"/>
<xsl:variable name="dstPopRef" select="../../@dst_population"/>
<Link>
        <Src><xsl:value-of select="translate(@name,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@output_src_port"/></Src>
        <Dst><xsl:value-of select="translate(../../@dst_population,' -', '_H')"/><xsl:if test="count(document(//SMLNL:Population[SMLNL:Neuron/@name=$dstPopRef]/SMLNL:Neuron/@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(//SMLNL:Population[SMLNL:Neuron/@name=$dstPopRef]/SMLNL:Neuron/@url)//SMLCL:EventReceivePort[@name=$dstPortRef]) or count(document(//SMLNL:Population[SMLNL:Neuron/@name=$dstPopRef]/SMLNL:Neuron/@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@output_dst_port"/></Dst>
	<Lag>0</Lag>
</Link>

</xsl:if>

</xsl:for-each>

<xsl:for-each select="//SMLNL:Input">
<xsl:variable name="dstPortRef" select="@dst_port"/>

<xsl:variable name="target_name" select="../../../@dst_population"/>
<xsl:variable name="source_name" select="../../../../SMLNL:Neuron/@name"/>

<!-- APPLY LESION -->
<xsl:if test="count($expt_root//SMLEXPT:Lesion[@src_population=$source_name and @dst_population=$target_name])=0">

<xsl:variable name="sizeIn">
<xsl:variable name="srcObjName" select="@src"/>
<xsl:for-each select="//*[@name=$srcObjName]">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../../../../SMLNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:ConnectionList)>0">
                <xsl:value-of select="count(../SMLNL:ConnectionList/SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
        <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>

<xsl:variable name="sizeOut">

<xsl:for-each select="..">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:Connection//SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../../../../SMLNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:Connection)>0">
                <xsl:value-of select="count(../SMLNL:Connection//SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>

<xsl:if test="count(.//SMLNL:AllToAllConnection)=1">
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/allToAll</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeIn"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	</State>
</Process>
<Link>
        <Src>
        <xsl:value-of select="translate(@src,' -', '_H')"/>
        <xsl:text disable-output-escaping="no">&gt;</xsl:text>
        <xsl:value-of select="@src_port"/></Src>
        <Dst>
        <xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inSpike<!---->
	</xsl:if>
        <xsl:if test="count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inImpulse<!---->
	</xsl:if>
	<xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=0 and count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=0">
		<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->in<!---->
	</xsl:if>
	</Dst>
        <Lag><xsl:if test="count(.//SMLNL:FixedValue)=1 and not(number(.//SMLNL:FixedValue/@value)=0)"><xsl:value-of select="number(.//SMLNL:FixedValue//SMLNL:Value)*number(10)"/></xsl:if><xsl:if test="not(count(.//SMLNL:FixedValue)=1) or number(.//SMLNL:FixedValue/@value)=0">1</xsl:if></Lag>
</Link>
<Link>
	<Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef]) or count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:if>



<xsl:if test="count(.//SMLNL:OneToOneConnection)=1">

<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef]) or count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>1</Lag>
</Link>
</xsl:if>



<xsl:if test="count(.//SMLNL:FixedProbabilityConnection)=1">
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/explicitList</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;p;seed;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeIn"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	<m c="f"><xsl:value-of select="@probability"/></m>
	<m c="f"><xsl:value-of select="@seed"/></m>
	</State>
</Process>
<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst>
        <xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inSpike<!---->
	</xsl:if>
        <xsl:if test="count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inImpulse<!---->
	</xsl:if>
	<xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=0 and count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=0">
		<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->in<!---->
	</xsl:if>
        </Dst>
        <Lag><xsl:if test="count(.//SMLNL:FixedValue)=1 and not(number(.//SMLNL:FixedValue/@value)=0)"><xsl:value-of select="number(.//SMLNL:FixedValue//SMLNL:Value)*number(10)"/></xsl:if><xsl:if test="not(count(.//SMLNL:FixedValue)=1) or number(.//SMLNL:FixedValue/@value)=0">1</xsl:if></Lag>
</Link>
<Link>
	<Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:if>



<xsl:if test="count(.//SMLNL:ConnectionList)=1">
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/explicitList</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;src;dst;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="$sizeIn"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
        <m><xsl:attribute name="b">1 <xsl:value-of select="count(.//SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
        <xsl:for-each select=".//SMLNL:Connection"><xsl:value-of select="@src_neuron"/><xsl:text> </xsl:text></xsl:for-each>
	</m>
        <m><xsl:attribute name="b">1 <xsl:value-of select="count(.//SMLNL:Connection)"/></xsl:attribute><xsl:attribute name="c">d</xsl:attribute>
        <xsl:for-each select=".//SMLNL:Connection"><xsl:value-of select="@dst_neuron"/><xsl:text> </xsl:text></xsl:for-each>
	</m>
	</State>
</Process>
<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst>
        <xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inSpike<!---->
	</xsl:if>
        <xsl:if test="count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1">
        	<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->inImpulse<!---->
	</xsl:if>
	<xsl:if test="count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=0 and count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=0">
		<xsl:text disable-output-escaping="no">&lt;</xsl:text>
		<!---->in<!---->
	</xsl:if>
        </Dst>
        <Lag><xsl:if test="count(.//SMLNL:FixedValue)=1 and not(number(.//SMLNL:FixedValue/@value)=0)"><xsl:value-of select="number(.//SMLNL:FixedValue//SMLNL:Value)*number(10)"/></xsl:if><xsl:if test="not(count(.//SMLNL:FixedValue)=1) or number(.//SMLNL:FixedValue/@value)=0">1</xsl:if></Lag>
</Link>
<Link>
	<Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:if>


<xsl:if test="count(./*)=0">
<Link>
        <Src><xsl:value-of select="translate(@src,' -', '_H')"/><xsl:text disable-output-escaping="no">&gt;</xsl:text><xsl:value-of select="@src_port"/></Src>
        <Dst><xsl:value-of select="translate(../@name,' -', '_H')"/><xsl:if test="count(document(../@url)//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:EventReceivePort[@name=$dstPortRef])=1 or count(document(../@url)//SMLCL:ImpulseReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@dst_port"/></Dst>
	<Lag>1</Lag>
</Link>
</xsl:if>

</xsl:if>
</xsl:for-each> <!-- END OF INPUTS -->

<!-- SOURCE INPUTS -->
<xsl:for-each select="$expt_root//SMLEXPT:Experiment/SMLEXPT:ConstantInput">
<Process>
	<Name><xsl:value-of select="concat('input',generate-id(.))"/></Name>
	<Class>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>dev/SpineML/tools/EventConstantInput</xsl:text>
		</xsl:if>
		<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
			<xsl:text>dev/SpineML/tools/AnalogConstantInput</xsl:text>
		</xsl:if>
	</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">
		<xsl:text>values;</xsl:text>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>rateType;</xsl:text>
		</xsl:if>
		</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m b="1 1" c="f"><xsl:value-of select="@value"/></m>
	<xsl:if test="@rate_based_input='poisson'">
		<m c="f">0</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='regular'">
		<m c="f">1</m>
	</xsl:if>
	</State>
</Process>

<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="targetFile" select="document($main_root//*[@name = $target]/@url)"/>

<!-- SIZE OUT FOR REMAP -->
<xsl:variable name="sizeOut">
<xsl:for-each select="$main_root//*[@name = $target]">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:Connection//SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../../../../SMLNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:Connection)>0">
                <xsl:value-of select="count(../SMLNL:Connection//SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>
<!-- END SIZE OUT FOR REMAP -->

<!-- ADD REMAP -->
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/allToAll</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="'1'"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	</State>
</Process>
<Link>
    <Src><xsl:value-of select="concat('input',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        <xsl:text disable-output-escaping="no">&lt;inSpike</xsl:text>
        </xsl:if>
        <xsl:if test="count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=0">
        <xsl:text disable-output-escaping="no">&lt;in</xsl:text>
        </xsl:if>
        </Dst>
	<Lag>0</Lag>
</Link>
<Link>
    <Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
    <Dst><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:if test="count($targetFile//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@port"/></Dst>
	<Lag>0</Lag>
</Link>

</xsl:if>
<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="targetFile" select="document($main_root/*[@name = $target]/@url)"/>
<xsl:variable name="idString" select="generate-id(.)"/>
<xsl:for-each select="$main_root//SMLNL:Population[SMLNL:Neuron/@name=$target]//SMLNL:Synapse">

<!-- SIZE OUT FOR REMAP -->
<xsl:variable name="sizeOut">
<xsl:for-each select="$main_root//*[@name = $target]">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:Connection//SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../../../../SMLNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:Connection)>0">
                <xsl:value-of select="count(../SMLNL:Connection//SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>
<!-- END SIZE OUT FOR REMAP -->

<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/allToAll</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="'1'"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	</State>
</Process>
<Link>
    <Src><xsl:value-of select="concat('input',$idString)"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:text disable-output-escaping="no">&lt;inSpike</xsl:text>
        </Dst>
	<Lag>0</Lag>
</Link>
<Link>
    <Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
    <Dst><xsl:value-of select="translate(SMLNL:WeightUpdate/@name,' -', '_H')"/>&lt;&lt;<xsl:value-of select="$dstPortRef"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:for-each>
</xsl:if>
</xsl:for-each>

<xsl:for-each select="$expt_root//SMLEXPT:Experiment/SMLEXPT:ConstantArrayInput">
<Process>
	<Name><xsl:value-of select="concat('input',generate-id(.))"/></Name>
	<Class>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>dev/SpineML/tools/EventConstantInput</xsl:text>
		</xsl:if>
		<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
			<xsl:text>dev/SpineML/tools/AnalogConstantInput</xsl:text>
		</xsl:if>
	</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">
		<xsl:text>values;</xsl:text>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>rateType;</xsl:text>
		</xsl:if>
		</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m>
		<xsl:attribute name="b">1 <xsl:value-of select="@array_size"/></xsl:attribute>
		<xsl:attribute name="c">f</xsl:attribute>
		<xsl:value-of select="translate(@array_value,',', ' ')"/>
	</m>
	<xsl:if test="@rate_based_input='poisson'">
		<m c="f">0</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='regular'">
		<m c="f">1</m>
	</xsl:if>
	</State>
</Process>
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="targetFile" select="document($main_root//*[@name = $target]/@url)"/>
<Link>
    <Src><xsl:value-of select="concat('input',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:if test="count($targetFile//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:for-each>

<xsl:for-each select="$expt_root//SMLEXPT:Experiment/SMLEXPT:TimeVaryingInput">
<Process>
	<Name><xsl:value-of select="concat('input',generate-id(.))"/></Name>
	<Class>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>dev/SpineML/tools/EventTimeVaryingInput</xsl:text>
		</xsl:if>
		<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
			<xsl:text>dev/SpineML/tools/AnalogTimeVaryingInput</xsl:text>
		</xsl:if>
	</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">
		<xsl:text>values;</xsl:text>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>rateType;</xsl:text>
		</xsl:if>
		</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m>
		<xsl:attribute name="b">2 <xsl:value-of select="count(SMLEXPT:TimePointValue)"/></xsl:attribute>
		<xsl:attribute name="c">f</xsl:attribute>
		<xsl:for-each select="SMLEXPT:TimePointValue">
		<xsl:value-of select="@time"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="@value"/>
		<xsl:text> </xsl:text>
		</xsl:for-each>
	</m>
	<xsl:if test="@rate_based_input='poisson'">
		<m c="f">0</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='regular'">
		<m c="f">1</m>
	</xsl:if>
	</State>
</Process>
<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="targetFile" select="document($main_root//*[@name = $target]/@url)"/>

<!-- SIZE OUT FOR REMAP -->
<xsl:variable name="sizeOut">
<xsl:for-each select="$main_root//*[@name = $target]">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:Connection//SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../../../../SMLNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:Connection)>0">
                <xsl:value-of select="count(../SMLNL:Connection//SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>
<!-- END SIZE OUT FOR REMAP -->

<!-- ADD REMAP -->
<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/allToAll</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="'1'"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	</State>
</Process>
<Link>
    <Src><xsl:value-of select="concat('input',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:if test="count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1">
        <xsl:text disable-output-escaping="no">&lt;inSpike</xsl:text>
        </xsl:if>
        <xsl:if test="count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=0">
        <xsl:text disable-output-escaping="no">&lt;in</xsl:text>
        </xsl:if>
        </Dst>
	<Lag>0</Lag>
</Link>
<Link>
    <Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
    <Dst><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:if test="count($targetFile//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@port"/></Dst>
	<Lag>0</Lag>
</Link>

</xsl:if>
<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="targetFile" select="document($main_root/*[@name = $target]/@url)"/>
<xsl:variable name="idString" select="generate-id(.)"/>
<xsl:for-each select="$main_root//SMLNL:Population[SMLNL:Neuron/@name=$target]//SMLNL:Synapse">

<!-- SIZE OUT FOR REMAP -->
<xsl:variable name="sizeOut">
<xsl:for-each select="$main_root//*[@name = $target]">
<xsl:if test="local-name(.)='Neuron'">
        <xsl:value-of select="@size"/>
</xsl:if>
<xsl:if test="local-name(.)='WeightUpdate'">
	<!-- THIS IS REALLY COMPLICATED -->
        <xsl:if test="count(../SMLNL:Connection//SMLNL:OneToOneConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:AllToAllConnection)=1">
                <xsl:variable name="ownerPopName" select="../../../../@dst_population"/>
                <xsl:variable name="dstPopSize" select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
                <xsl:variable name="srcPopSize" select="../../../../../../SMLNL:Neuron/@size"/>
		<xsl:value-of select="number($srcPopSize) * number($dstPopSize)"/>
	</xsl:if>
        <xsl:if test="count(../SMLNL:Connection//SMLNL:Connection)>0">
                <xsl:value-of select="count(../SMLNL:Connection//SMLNL:Connection)"/>
	</xsl:if>	
</xsl:if>
<xsl:if test="local-name(.)='PostSynapse'">
        <xsl:variable name="ownerPopName" select="../../@dst_population"/>
        <xsl:value-of select="/SMLNL:SpineML//SMLNL:Neuron[SMLNL:Name=$ownerPopName]/@size"/>
</xsl:if>
</xsl:for-each>
</xsl:variable>
<!-- END SIZE OUT FOR REMAP -->

<Process>
	<Name><xsl:value-of select="concat('remap',generate-id(.))"/></Name>
	<Class>dev/SpineML/tools/allToAll</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">sizeIn;sizeOut;</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<m c="f"><xsl:value-of select="'1'"/></m>
	<m c="f"><xsl:value-of select="$sizeOut"/></m>
	</State>
</Process>
<Link>
    <Src><xsl:value-of select="concat('input',$idString)"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="concat('remap',generate-id(.))"/>
        <xsl:text disable-output-escaping="no">&lt;inSpike</xsl:text>
        </Dst>
	<Lag>0</Lag>
</Link>
<Link>
    <Src><xsl:value-of select="concat('remap',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
    <Dst><xsl:value-of select="translate(SMLNL:WeightUpdate/@name,' -', '_H')"/>&lt;&lt;<xsl:value-of select="$dstPortRef"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:for-each>
</xsl:if>
</xsl:for-each>

<xsl:for-each select="$expt_root//SMLEXPT:Experiment/SMLEXPT:TimeVaryingArrayInput">
<Process>
	<Name><xsl:value-of select="concat('input',generate-id(.))"/></Name>
	<Class>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>dev/SpineML/tools/EventTimeVaryingInput</xsl:text>
		</xsl:if>
		<xsl:if test="not(@rate_based_input='poisson' or @rate_based_input='regular')">
			<xsl:text>dev/SpineML/tools/AnalogTimeVaryingInput</xsl:text>
		</xsl:if>
	</Class>
	<Time>
		<SampleRate><xsl:value-of select="$sampleRate"/></SampleRate>
	</Time>
	<State>
	<xsl:attribute name="c">z</xsl:attribute>
	<xsl:attribute name="a">
		<xsl:for-each select="SMLEXPT:TimePointArrayValue">
			<xsl:value-of select="concat('values',@index)"/>;<!---->
		</xsl:for-each>
		<xsl:if test="@rate_based_input='poisson' or @rate_based_input='regular'">
			<xsl:text>rateType;</xsl:text>
		</xsl:if>
		</xsl:attribute>
	<xsl:attribute name="Format">DataML</xsl:attribute>
	<xsl:attribute name="Version">5</xsl:attribute>
	<xsl:attribute name="AuthTool">SpineML to BRAHMS XSLT translator</xsl:attribute>
	<xsl:attribute name="AuthToolVersion">0</xsl:attribute>
	<xsl:for-each select="SMLEXPT:TimePointArrayValue">
	<m>
		<xsl:attribute name="b">2 <xsl:call-template name="count_array_items"><xsl:with-param name="items" select="@array_value"/></xsl:call-template></xsl:attribute>
		<xsl:attribute name="c">f</xsl:attribute>
		<xsl:value-of select="translate(@array_time,',',' ')"/>
		<xsl:text> </xsl:text>
		<xsl:value-of select="translate(@array_value,',',' ')"/>
		<xsl:text> </xsl:text>
	</m>
	</xsl:for-each>
	<xsl:if test="@rate_based_input='poisson'">
		<m c="f">0</m>
	</xsl:if>
	<xsl:if test="@rate_based_input='regular'">
		<m c="f">1</m>
	</xsl:if>
	</State>
</Process>
<xsl:variable name="dstPortRef" select="@port"/>
<xsl:variable name="target" select="@target"/>
<xsl:variable name="targetFile" select="document($main_root//*[@name = $target]/@url)"/>
<Link>
    <Src><xsl:value-of select="concat('input',generate-id(.))"/><xsl:text disable-output-escaping="no">&gt;</xsl:text>out</Src>
        <Dst><xsl:value-of select="translate(@target,' -', '_H')"/><xsl:if test="count($targetFile//SMLCL:AnalogReducePort[@name=$dstPortRef])=1 or count($targetFile//SMLCL:EventReceivePort[@name=$dstPortRef])=1"><xsl:text disable-output-escaping="no">&lt;</xsl:text></xsl:if><xsl:text disable-output-escaping="no">&lt;</xsl:text><xsl:value-of select="@port"/></Dst>
	<Lag>0</Lag>
</Link>
</xsl:for-each>


</System>

</xsl:for-each>

</xsl:template>

</xsl:stylesheet>


