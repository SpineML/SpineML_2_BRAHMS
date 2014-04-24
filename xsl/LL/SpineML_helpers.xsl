<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:template name="alias_replace_helper">

	<xsl:param name="start"/>
	<xsl:param name="end"/>	
	<xsl:param name="allaliases"/>
	<xsl:param name="aliases"/>
	<xsl:param name="alias"/>
	<xsl:param name="params"/>
	<xsl:param name="have_made_a_substitution" select="0"/>
	<xsl:choose>
		<xsl:when test="contains($end,$alias)">
		<xsl:variable name="startTemp" select="concat($start,substring-before($end,$alias))"/>
		<xsl:variable name="endTemp" select="substring-after($end,$alias)"/>			
		<xsl:variable name="math" select = "$aliases[1]/SMLCL:MathInline"/>
			<xsl:choose>
			<xsl:when test="contains('+-*/() =,&lt;&gt;',substring($startTemp,string-length($startTemp),1)) and contains('+-*/() =,&lt;&gt;',substring($endTemp,1,1))">
			<xsl:call-template name="alias_replace_helper">
				<xsl:with-param name="allaliases" select="$allaliases"/>
				<xsl:with-param name="aliases" select="$aliases"/>
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="alias" select="$alias"/>
				<xsl:with-param name="start" select="concat($startTemp,'(',$math,')')"/>
				<xsl:with-param name="end" select="$endTemp"/>
				<xsl:with-param name="have_made_a_substitution" select="1"/>
			</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
			<xsl:call-template name="alias_replace_helper">
				<xsl:with-param name="allaliases" select="$allaliases"/>
				<xsl:with-param name="aliases" select="$aliases"/>
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="alias" select="$alias"/>
				<xsl:with-param name="start" select="concat($startTemp,$alias)"/>
				<xsl:with-param name="end" select="$endTemp"/>
				<xsl:with-param name="have_made_a_substitution" select="$have_made_a_substitution"/>
			</xsl:call-template>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="alias_replace">
				<xsl:with-param name="allaliases" select="$allaliases"/>
				<xsl:with-param name="aliases" select="$aliases[position() > 1]"/>
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="string" select="concat($start,$end)"/>
				<xsl:with-param name="aliasreplaced" select="$have_made_a_substitution"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template name="alias_replace">

	<xsl:param name="params"/>
	<xsl:param name="aliases"/>
	<xsl:param name="string"/>
	<xsl:param name="aliasreplaced" select="0"/>
	<xsl:param name="allaliases" select="$aliases"/>
	<xsl:choose>
	<xsl:when test="not($aliases) and $aliasreplaced=0">
	<xsl:call-template name="add_indices">
		<xsl:with-param name="params" select="$params"/>
		<xsl:with-param name="string" select="$string"/>
	</xsl:call-template>
	</xsl:when>
	<xsl:when test="not($aliases) and $aliasreplaced=1">
	<xsl:call-template name="alias_replace">
		<xsl:with-param name="allaliases" select="$allaliases"/>
		<xsl:with-param name="aliases" select="$allaliases"/>
		<xsl:with-param name="params" select="$params"/>
		<xsl:with-param name="string" select="$string"/>
		<xsl:with-param name="aliasreplaced" select="0"/>
	</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	<xsl:variable name="alias" select = "$aliases[1]/@name"/>
	<xsl:choose>
	<xsl:when test="contains($string,$alias)">
	<xsl:call-template name="alias_replace_helper">
		<xsl:with-param name="allaliases" select="$allaliases"/>
		<xsl:with-param name="aliases" select="$aliases"/>
		<xsl:with-param name="alias" select="$alias"/>
		<xsl:with-param name="start" select="@thisshouldnotexist"/>
		<xsl:with-param name="end" select="$string"/>
		<xsl:with-param name="params" select="$params"/>
	</xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	<xsl:call-template name="alias_replace">
		<xsl:with-param name="allaliases" select="$allaliases"/>
		<xsl:with-param name="aliases" select="$aliases[position() > 1]"/>
		<xsl:with-param name="params" select="$params"/>
		<xsl:with-param name="string" select="$string"/>
		<xsl:with-param name="aliasreplaced" select="$aliasreplaced"/>
	</xsl:call-template>
	</xsl:otherwise>
	</xsl:choose>
	</xsl:otherwise>
	</xsl:choose>

</xsl:template>
	
<xsl:template name="add_indices_helper">

	<xsl:param name="start"/>
	<xsl:param name="end"/>	
	<xsl:param name="params"/>
	<xsl:param name="aliases"/>
	<xsl:param name="param"/>
	<xsl:choose>
		<xsl:when test="contains($end,$param)">
		<xsl:variable name="startTemp" select="concat($start,substring-before($end,$param))"/>
		<xsl:variable name="endTemp" select="substring-after($end,$param)"/>
			<xsl:choose>
			<xsl:when test="contains('+-*/() =,&lt;&gt;',substring($startTemp,string-length($startTemp),1))">
			<xsl:choose>
			<xsl:when test="contains('+-*/() =,&lt;&gt;',substring($endTemp,1,1))">
				<xsl:call-template name="add_indices_helper">
					<xsl:with-param name="params" select="$params"/>
					<xsl:with-param name="param" select="$param"/>
					<xsl:with-param name="start" select="concat($startTemp,$param,'[num_BRAHMS]')"/>
					<xsl:with-param name="end" select="$endTemp"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
			<xsl:call-template name="add_indices_helper">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="param" select="$param"/>
				<xsl:with-param name="start" select="concat($startTemp,$param)"/>
				<xsl:with-param name="end" select="$endTemp"/>
			</xsl:call-template>
			</xsl:otherwise>
			</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
			<xsl:call-template name="add_indices_helper">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="param" select="$param"/>
				<xsl:with-param name="start" select="concat($startTemp,$param)"/>
				<xsl:with-param name="end" select="$endTemp"/>
			</xsl:call-template>
			</xsl:otherwise>
			</xsl:choose>			
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="add_indices">
				<xsl:with-param name="params" select="$params[position() > 1]"/>
				<xsl:with-param name="string" select="concat($start,$end)"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>

<xsl:template name="add_indices">

	<xsl:param name="params"/>
	<xsl:param name="string"/>
	<xsl:choose>
		<xsl:when test="not($params)">
<xsl:value-of select="$string"/>
		</xsl:when>
		<xsl:otherwise>
		<xsl:variable name="param" select = "$params[1]/@name"/>
			<xsl:choose>
			<xsl:when test="contains($string,$param)">
			<xsl:call-template name="add_indices_helper">
				<xsl:with-param name="params" select="$params"/>
				<xsl:with-param name="param" select="$param"/>
				<xsl:with-param name="start" select="@thisshouldnotexist"/>
				<xsl:with-param name="end" select="$string"/>
			</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
			<xsl:call-template name="add_indices">
	
			<xsl:with-param name="params" select="$params[position() > 1]"/>
				<xsl:with-param name="string" select="$string"/>
			</xsl:call-template>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>

</xsl:template>	

</xsl:stylesheet>
