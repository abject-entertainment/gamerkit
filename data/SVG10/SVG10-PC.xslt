<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template name="js_boilerplate">
		current_block = document.getElementById("scroll_lock");
		tmpl = new list_template("Skill");
			tmpl.add_attribute("name", "Skill", TYPE_string, "");
			tmpl.add_attribute("rank", "Rank", TYPE_option, 
			{"4":"d4","6":"d6","8":"d8","10":"d10","12":"d12"});
			tmpl.post_construct = function(item)
			{
				add_die_roll(item, "1da[.rank]+1da6", "[.name] Check: %t");
			}
		register_template(tmpl);
		
		tmpl = new list_template("Power");
			tmpl.collapse = true;
			tmpl.add_attribute("name", null, TYPE_string, "");
			tmpl.add_attribute("trapping", "Trapping", TYPE_string, "");
			tmpl.add_attribute("cost", "Cost", TYPE_int, "0");
			tmpl.add_attribute("range", "Range", TYPE_string, "");
			tmpl.add_attribute("duration", "Duration", TYPE_string, "");
			tmpl.add_attribute("effect", "Damage/Effect", TYPE_text, "");
//			tmpl.post_construct = function(item)
//			{
//				add_die_roll(item, "[.name]: Attack=1d20+[.bonus],Damage=[.damage]");
//			}
		register_template(tmpl);
		
		tmpl = new list_template("Weapon");
			tmpl.collapse = true;
			tmpl.add_attribute("name", null, TYPE_string, "");
			tmpl.add_attribute("range", "Range", TYPE_string, "");
			tmpl.add_attribute("rof", "ROF", TYPE_int, "");
			tmpl.add_attribute("ap", "AP", TYPE_int, "");
			tmpl.add_attribute("damage", "Damage", TYPE_int, "");
			tmpl.add_attribute("wt", "WT", TYPE_int, "");
			tmpl.add_attribute("notes", "Notes", TYPE_text, "");
			tmpl.post_construct = function(item)
			{
				add_die_roll(item, "[damage]", "[.name] Damage: %t");
			}
		register_template(tmpl);
		
		function vitals_header()
		{
           	if (format == "ipad")
           	{
	            block_columns("vitals");
	            	block_column("col_tok_" + format);
						attribute("Token", null, TYPE_token, "<xsl:apply-templates select="character/attribute[@name='Token']" />");
	            	endblock();
	            	block_column("col_vitals_" + format);
           	}
           	else
           	{
           		block_plain("vitals");
           	}
					attribute("Name", "Character Name", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Name']" />", (format==='ipad')?"line_2":"line_2");
                    attribute("Player", "Player Name", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Player']" />", (format==='ipad')?"line_2":"line_2");
					attribute("Origin", "Origin", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Origin']" />", "line_2");
					attribute("Rating", "Rating/XP", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Rating']" />", "line_2");
					attribute("Wounds", "Wounds", TYPE_slider, ["<xsl:apply-templates select="character/attribute[@name='Wounds']" />", 4], (format==='ipad')?"line_2":"line_3");
					attribute("Fatigue", "Fatigue", TYPE_slider, ["<xsl:apply-templates select="character/attribute[@name='Fatigue']" />", 3], (format==='ipad')?"line_2":"line_3");
					if (format==='ipad') { page_stats(); }
					attribute("Bennies", "Bennies", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Bennies']" />", (format==='ipad')?"line_10":"line_3");
			if (format == "ipad")
			{
				endblock();
			}
			endblock();
		}
		function page_stats()
		{
			if (format == "iphone") {
				block_page("stats", "Stats");
				block_plain("primary");
			}
					a = attribute("Agility", "Agility", TYPE_option, 
						{ attr_value:"<xsl:apply-templates select="character/attribute[@name='Agility']" />",
						"4":"d4", "6":"d6", "8":"d8", "10":"d10", "12":"d12"}, (format=='ipad')?"line_10":"char_attr"); 
					add_die_roll(a,"1da[Agility]+1da6", ["Agility Check: %t"]);
					a = attribute("Smarts", "Smarts", TYPE_option, 
						{ attr_value:"<xsl:apply-templates select="character/attribute[@name='Smarts']" />",
						"4":"d4", "6":"d6", "8":"d8", "10":"d10", "12":"d12"}, (format=='ipad')?"line_10":"char_attr"); 
					add_die_roll(a,"1da[Smarts]+1da6", ["Smarts Check: %t"]);
					a = attribute("Strength", "Strength", TYPE_option, 
						{ attr_value:"<xsl:apply-templates select="character/attribute[@name='Strength']" />",
						"4":"d4", "6":"d6", "8":"d8", "10":"d10", "12":"d12"}, (format=='ipad')?"line_10":"char_attr"); 
					add_die_roll(a,"1da[Strength]+1da6", ["Strength Check: %t"]);
					a = attribute("Spirit", "Spirit", TYPE_option, 
						{ attr_value:"<xsl:apply-templates select="character/attribute[@name='Spirit']" />",
						"4":"d4", "6":"d6", "8":"d8", "10":"d10", "12":"d12"}, (format=='ipad')?"line_10":"char_attr"); 
					add_die_roll(a,"1da[Spirit]+1da6", ["Spirit Check: %t"]);
					a = attribute("Vigor", "Vigor", TYPE_option, 
						{ attr_value:"<xsl:apply-templates select="character/attribute[@name='Vigor']" />",
						"4":"d4", "6":"d6", "8":"d8", "10":"d10", "12":"d12"}, (format=='ipad')?"line_10":"char_attr"); 
					add_die_roll(a,"1da[Vigor]+1da6", ["Vigor Check: %t"]);
			if (format == 'iphone') {
				endblock();
				block_plain("secondary");
			}
					a = attribute("Charisma", "Charisma", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Charisma']" />", (format=='ipad')?"line_10":"char_attr"); 
					a = attribute("Pace", "Pace", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Pace']" />", (format=='ipad')?"line_10":"char_attr"); 
					a = attribute("Parry", "Parry", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Parry']" />", (format=='ipad')?"line_10":"char_attr"); 
					a = attribute("Toughness", "Tough.", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Toughness']" />", (format=='ipad')?"line_10":"char_attr"); 
					if (format === 'iphone')
					{
						attribute("Token", null, TYPE_token, "<xsl:apply-templates select="character/attribute[@name='Token']" />");
					}
			if (format == 'iphone'){
				endblock();
				endblock();
			}
		}
		
		function page_skills()
		{
			block_page("skills_block", "Abilities");
				block_list("Skills", "Skill", "Skills", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Skills']" />
				endblock();
				block_list("Hindrances", "StringList", "Hindrances", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Hindrances']" />
				endblock();
				block_list("Edges", "StringList", "Edges", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Edges']" />
				endblock();
				block_list("Powers", "Power", "Powers &amp; Trappings", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Powers']" />
				endblock();
				attribute("PowerPoints", "Power Points", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='PowerPoints']" />", "line_1");
			endblock();
		}
		
		function page_loot()
		{
			block_page("loot", "Stuff");
				attribute("Wealth", "Money", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Wealth']" />", "major_section");
				block_list("Equipment", "StringList", "Equipment", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Equipment']" />
				endblock();
				block_list("Weapons", "Weapon", "Weapons", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Weapons']" />
				endblock();
					attribute("ArmorHead", "Head Armor", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='ArmorHead']" />", "line_2");
					attribute("ArmorTorso", "Torso Armor", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='ArmorTorso']" />", "line_2");
					attribute("ArmorArms", "Arms Armor", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='ArmorArms']" />", "line_2");
					attribute("ArmorLegs", "Legs Armor", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='ArmorLegs']" />", "line_2");
					attribute("WTCarried", "Total WT Carried", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='WTCarried']" />", "line_3");
					attribute("WTLimit", "Weight Limit", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='WTLimit']" />", "line_3");
					attribute("WTPenalty", "Enc. Penalty", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='WTPenalty']" />", "line_3");
				endblock();
		}
		
		function page_notes()
		{
			block_page("notes", "Notes");
				attribute("Description", "Description", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Description']" />", "major_section");
				attribute("Personality", "Personality", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Personality']" />", "major_section");
				attribute("Background", "Background", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Background']" />", "major_section");
				attribute("Notes", "Notes", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Notes']" />", "major_section");
			endblock();
		}
	</xsl:template>
	
	<xsl:template match="attribute[@name='Skills']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"rank":"<xsl:value-of select="rank" />"});
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="attribute[@name='Powers']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"trapping":"<xsl:value-of select="trapping" />",
				"cost":"<xsl:value-of select="cost" />",
				"range":"<xsl:value-of select="range" />",
				"effect":"<xsl:value-of select="effect" />",
				"duration":"<xsl:value-of select="duration" />"});
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="attribute[@name='Weapons']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"range":"<xsl:value-of select="range" />",
				"rof":"<xsl:value-of select="rof" />",
				"damage":"<xsl:value-of select="damage" />",
				"ap":"<xsl:value-of select="ap" />",
				"wt":"<xsl:value-of select="wt" />",
				"notes":"<xsl:value-of select="notes" />"});
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="attribute[@name='Equipment']|attribute[@name='Hindrances']|attribute[@name='Edges']">
		<xsl:for-each select="item">
			list_item({"s":"<xsl:value-of select="." />"});
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="attribute[@name='DieRolls']">
		<xsl:for-each select="item">
			{"name":"<xsl:value-of select="name" />",
			"roll":"<xsl:value-of select="roll" />"},
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>