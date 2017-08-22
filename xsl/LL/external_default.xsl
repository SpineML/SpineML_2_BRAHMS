<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="fn">
<xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="yes"/>

<!--
    This is a placeholder - a no-op template. It allows you to have
    additional content added to the sys.xml file which BRAHMS
    uses. The reason for its existence is to allow you to "splice in"
    external BRAHMS components to your neural network models.
-->

<!-- The spineml_output_dir is passed in -->
<xsl:param name="spineml_output_dir" select="'./'"/>

<!-- START TEMPLATE -->
<xsl:template name="external">

<xsl:comment>Any external modifications to sys.xml can go here.</xsl:comment>

<!-- GET A LINK TO THE EXPERIMENT FILE FOR LATER USE -->
<xsl:variable name="expt_root" select="/"/>

<!-- GET THE SAMPLE RATE -->
<xsl:variable name="sampleRate" select="(1 div number($expt_root//@dt)) * 1000.0"/>

<!--
    Change the processes and links below to "shim in" your
    external/handcoded BRAHMS components and link them to selected
    parts of your SpineML model.
-->

<!-- An example process -->
<!--
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
-->

<!-- An example link -->
<!--
<Link>
	<Src>MN_up&gt;a</Src>
	<Dst>SaccSim&lt;&lt;&lt;suprect</Dst>
	<Lag>0</Lag>
</Link>
-->

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
