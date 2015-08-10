<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!--
     This template adds the Processes and Links necessary to connect
     in the Patra-developed and Seb-brahms-wrapped biomechanical eye
     model.

     Currently, this DEPENDS on the SpineML model being the
     Oculomotor model with saccade generator and on correct naming of
     the outputs of the saccade generator (MN up/down, MN left/right)

     It also requires that the user has compiled the saccsim code,
     including the component.so BRAHMS component, and installed that
     in dev/NoTremor/saccsim within the BRAHMS Namespace dirs that are
     being used by SpineML_2_BRAHMS.
-->

<xsl:param name="spineml_output_dir" select="'./'"/>

<!-- START TEMPLATE -->
<xsl:template name="saccsimOculomotor">

<xsl:comment>Generated by Saccsim_Oculomotor.xsl</xsl:comment>

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!-- GET A LINK TO THE NETWORK FILE FOR LATER USE -->
<!-- <xsl:variable name="main_root" select="/"/> -->

<!-- This is the destination process - the Saccade simulator itself. -->
<Process>
	<Name>SaccSim</Name>
	<Class>dev/NoTremor/saccsim</Class>
	<State c="z" a="output_data_path;simtk_integrator;" Format="DataML" Version="5" AuthTool="SystemML Toolbox" AuthToolVersion="0">
		<m><xsl:value-of select="$spineml_output_dir"/></m>
		<m>ExplicitEuler</m>
	</State>
	<Time><SampleRate><xsl:value-of select="$sampleRate"/></SampleRate></Time>
	<State></State>
</Process>

<Process>
	<Name>Zeroes</Name>
	<Class>std/2009/source/numeric</Class>
	<Time><SampleRate><xsl:value-of select="$sampleRate"/></SampleRate></Time>
	<State c="z" a="data;repeat;" Format="DataML" Version="5" AuthTool="SystemML Toolbox" AuthToolVersion="0">
		<m b="1 1" c="d">0</m>
		<m c="l">1</m>
	</State>
</Process>

<!-- Here, we link each muscle input activity process to the Saccade simulator. -->
<Link>
	<Src>MN_up&gt;a</Src>
	<Dst>SaccSim&lt;&lt;&lt;suprect</Dst>
	<Lag>0</Lag>
</Link>
<Link>
	<Src>MN_down&gt;a</Src>
	<Dst>SaccSim&lt;&lt;&lt;infrect</Dst>
	<Lag>0</Lag>
</Link>
<Link>
	<Src>MN_right&gt;a</Src>
	<Dst>SaccSim&lt;&lt;&lt;medrect</Dst>
	<Lag>0</Lag>
</Link>
<Link>
	<Src>MN_left&gt;a</Src>
	<Dst>SaccSim&lt;&lt;&lt;latrect</Dst>
	<Lag>0</Lag>
</Link>
<Link>
	<Src>Zeroes&gt;out</Src>
	<Dst>SaccSim&lt;&lt;&lt;supobl</Dst>
	<Lag>0</Lag>
</Link>
<Link>
	<Src>Zeroes&gt;out</Src>
	<Dst>SaccSim&lt;&lt;&lt;infobl</Dst>
	<Lag>0</Lag>
</Link>

<!-- This is the world data maker process. Saccade simulator feeds rotations into this process. -->
<Process>
	<Name>WorldDataMaker</Name>
	<Class>dev/NoTremor/worldDataMaker</Class>
	<State c="z" a="output_data_path;neuronsPerPopulation;" Format="DataML" Version="5" AuthTool="SystemML Toolbox" AuthToolVersion="0">
		<m><xsl:value-of select="$spineml_output_dir"/></m>
                <m c="f">2500</m>
	</State>
	<Time><SampleRate><xsl:value-of select="$sampleRate"/></SampleRate></Time>
	<State></State>
</Process>

<!-- Rotations output from Saccsim is input to WorldDataMaker component -->
<Link>
	<Src>SaccSim&gt;out</Src>
	<Dst>WorldDataMaker&lt;&lt;&lt;rotationsIn</Dst>
	<Lag>0</Lag>
</Link>

<!-- Output from WorldDataMaker is fed into the World population, which
     then gates this with MN output and feeds it into Retina_1 and Retina_2 -->
<Link>
	<Src>WorldDataMaker&gt;corticalSheet</Src>
	<Dst>World&lt;in</Dst>
	<Lag>0</Lag>
</Link>

<!-- The centroid computation component -->
<Process>
	<Name>centroid</Name>
	<Class>dev/NoTremor/multicentroid</Class>
	<State c="z" a="neuronsPerPopulation;centroid_radius;" Format="DataML" Version="5" AuthTool="SystemML Toolbox" AuthToolVersion="0">
                <m c="f">2500</m>
                <m c="f">5</m>
	</State>
	<Time><SampleRate><xsl:value-of select="$sampleRate"/></SampleRate></Time>
	<State></State>
</Process>

<!-- From SC_deep we feed centroid... -->
<Link>
	<Src>SC_deep&gt;out</Src>
	<Dst>centroid&lt;&lt;&lt;inputSheet</Dst>
	<Lag>0</Lag>
</Link>

<!-- Output from centroid is fed into the SC_deep_output population -->
<Link>
	<Src>centroid&gt;centroid</Src>
	<Dst>SC_avg&lt;in</Dst>
	<Lag>0</Lag>
</Link>

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
