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
    parts of your SpineML model. These bits of XML are written in
    "DataML" which is an internal and undocumented markup language
    used by BRAHMS. There's a little help below in this file.
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

<!--
Some DataML help:

This stuff:
        <State c="z" a="data;repeat;" Format="DataML" Version="5" AuthTool="SystemML Toolbox" AuthToolVersion="0">
		<m b="1 1" c="d">0</m>
		<m c="l">1</m>
	</State>

Says that an element called <State/> is a DataMLNode which is of type
"z" - the attribute "c" is used to mean "type". "z" means that the
type is a data structure - a struct in C or C++. The State node
contains some sub-members called "data" and "repeat". Ignore the rest
of the attributes of State (Format, Version Authtool and
AuthToolVersion).

Now look within <State/> to look at "data" and "repeat". The <m/>
elements are the structure member objects - "data" and "repeat"; the
first <m/> is "data", the second is "repeat". Again, attribute "c" is
the type of the object referred to by the element. Attribute "b" is
the dimensions of the thing that <m/> refers to - I think if "b" is
present then that thing is considered to be a matrix. b="1 1" says
that the "data" <m/> is a 1x1 matrix. c="d" means the type of the
matrix elements is DOUBLE. So, data is 1 by 1 matrix of DOUBLEs with
value 0 (If there are multiple values for an MxN array, space separate
the values). repeat is a value rather than an array (no "b") and is of
type BOOL8, which is what c="l" means. Its value 1 a.k.a. true.

Cryptic. Here are all the types (the options for c attributes):

switch(c)
{
case 'd': cache.type = TYPE_DOUBLE; break;
case 'f': cache.type = TYPE_SINGLE; break;

case 'v': cache.type = TYPE_UINT64; break;
case 'u': cache.type = TYPE_UINT32; break;
case 't': cache.type = TYPE_UINT16; break;
case 's': cache.type = TYPE_UINT8; break;

case 'p': cache.type = TYPE_INT64; break;
case 'o': cache.type = TYPE_INT32; break;
case 'n': cache.type = TYPE_INT16; break;
case 'm': cache.type = TYPE_INT8; break;

case 'l': cache.type = TYPE_BOOL8; break;
case 'c': cache.type = TYPE_CHAR16; break;

case 'y': cache.type = TYPE_CELL; break;
case 'z': cache.type = TYPE_STRUCT; break;

See brahms-c++-common.h for more details. If there is no c attribute,
then the type is 'string'.

Heres' how it *could* have looked:

<State type="struct" members="data;repeat;" Format="DataML" Version="5" AuthTool="SystemML Toolbox" AuthToolVersion="0">
  <member arraysize="1 1" type="double">0</member>
  <member type="bool">1</member>
</State>

-->

<!-- END TEMPLATE -->
</xsl:template>

</xsl:stylesheet>
