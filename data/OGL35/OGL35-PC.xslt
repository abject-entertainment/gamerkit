<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template name="js_boilerplate">
		var stored_attributes = new Array();
		
		function compute_bonus(l,a)
		{
			var b = Math.floor(a.value / 2) - 5;
			if (b &gt; 0)
				l.innerText = "( +" + b + " )";
			else
				l.innerText = "( " + b + " )";
			eval(l.id + "=" + b);
		}
		
		var size_bonus = {"f":-8, "d":-4, "t":-2, "s":-1, "m":0, "l":+1, "h":+2, "g":+4, "c":+8};
		function compute_cmb(l,a)
		{
			var bab = Math.floor(stored_attributes["BAB"].value_node.value);
			var str = Math.floor(stored_attributes["Str"].value_node.value / 2) - 5;
			var siz = size_bonus[stored_attributes["Size"].value_node.value.toLowerCase().charAt(0)];
			if (siz == undefined) siz = 0;
			
			l.value_node.innerText = "+" + (bab+str+siz);
		}
		function compute_cmd(l,a)
		{
			var bab = Math.floor(stored_attributes["BAB"].value_node.value);
			var str = Math.floor(stored_attributes["Str"].value_node.value / 2) - 5;
			var dex = Math.floor(stored_attributes["Dex"].value_node.value / 2) - 5;
			var siz = size_bonus[stored_attributes["Size"].value_node.value.toLowerCase().charAt(0)];
			if (siz == undefined) siz = 0;
			
			l.value_node.innerText = bab+str+dex+siz+10;
		}
		
		tmpl = new list_template("Skill");
			tmpl.add_attribute("class-skill", "Class", TYPE_bool, "false");
			tmpl.add_attribute("name", "Skill", TYPE_string, "");
			tmpl.add_attribute("bonus", "Bonus", TYPE_string, "");
			tmpl.add_attribute("attribute", "Attr", TYPE_option, {"Str":"STR","Dex":"DEX","Con":"CON","Int":"INT","Wis":"WIS","Cha":"CHA"});
			tmpl.post_construct = function(item)
			{
				add_die_roll(item, "[.name] Check=1d20+[.bonus]");
			}
		register_template(tmpl);
		
		tmpl = new list_template("Attack");
			tmpl.collapse = true;
			tmpl.add_attribute("name", "Weapon", TYPE_string, "");
			tmpl.add_attribute("bonus", "Bonus", TYPE_int, "0");
			tmpl.add_attribute("damage", "Dmg", TYPE_string, "");
			tmpl.add_attribute("critical", "Crit", TYPE_string, "");
			tmpl.add_attribute("range", "Rng", TYPE_string, "");
			tmpl.add_attribute("type", "Type", TYPE_string, "");
			tmpl.add_attribute("ammo-type", "Ammo", TYPE_string, "");
			tmpl.add_attribute("ammo-count", "#", TYPE_int, "");
			tmpl.add_attribute("notes", "Notes", TYPE_text, "");
			tmpl.post_construct = function(item)
			{
				add_die_roll(item, "[.name]: Attack=1d20+[.bonus],Damage=[.damage]");
			}
		register_template(tmpl);
		
		tmpl = new list_template("Armor");
			tmpl.collapse = true;
			tmpl.add_attribute("name", "Armor/Shield", TYPE_string, "");
			tmpl.add_attribute("type", "Type", TYPE_string, "");
			tmpl.add_attribute("ac-bonus", "AC Bonus", TYPE_int, "");
			tmpl.add_attribute("max-dex", "Max Dex", TYPE_int, "");
			tmpl.add_attribute("check-penalty", "Chk Pnlty", TYPE_int, "");
			tmpl.add_attribute("spell-fail", "Spell Fail", TYPE_int, "");
			tmpl.add_attribute("weight", "Weight", TYPE_string, "");
			tmpl.add_attribute("properties", "Properties", TYPE_string, "");
		register_template(tmpl);
		
		tmpl = new list_template("SpellCap");
			tmpl.add_attribute("known", "# Known", TYPE_int, "");
			tmpl.add_attribute("save-dc", "Save DC", TYPE_int, "");
			tmpl.add_attribute("level", "Level", TYPE_label, "0");
			tmpl.add_attribute("per-day", "Per Day", TYPE_int, "");
			tmpl.add_attribute("bonus", "Bonus Spells", TYPE_int, "");
		register_template(tmpl);
		
		function page_stats()
		{
			block_page("stats", "Stats");
				block_columns("stats_columns");
					block_column("stats_attribs");
						line(); 
							a = attribute("Str", "STR", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Str']" />", "char_attr"); 
							attach_attribute(attribute("StrBonus", null, TYPE_label, "", "char_attr_bonus"), a.value_node, compute_bonus);
							stored_attributes["Str"] = a;
						a = endline();
						add_die_roll(a,"Strength Check=1d20+{StrBonus}");
						line();
							a = attribute("Dex", "DEX", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Dex']" />", "char_attr");
							attach_attribute(attribute("DexBonus", null, TYPE_label, "", "char_attr_bonus"), a.value_node, compute_bonus);
							stored_attributes["Dex"] = a;
						a = endline();
						add_die_roll(a,"Dexterity Check=1d20+{DexBonus}");
						line();
							a = attribute("Con", "CON", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Con']" />", "char_attr");
							attach_attribute(attribute("ConBonus", null, TYPE_label, "", "char_attr_bonus"), a.value_node, compute_bonus);
							stored_attributes["Con"] = a;
						a = endline();
						add_die_roll(a,"Constitution Check=1d20+{ConBonus}");
						line();
							a = attribute("Int", "INT", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Int']" />", "char_attr");
							attach_attribute(attribute("IntBonus", null, TYPE_label, "", "char_attr_bonus"), a.value_node, compute_bonus);
							stored_attributes["Int"] = a;
						a = endline();
						add_die_roll(a,"Intelligence Check=1d20+{IntBonus}");
						line();
							a = attribute("Wis", "WIS", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Wis']" />", "char_attr");
							attach_attribute(attribute("WisBonus", null, TYPE_label, "", "char_attr_bonus"), a.value_node, compute_bonus);
							stored_attributes["Wis"] = a;
						a = endline();
						add_die_roll(a,"Wisdom Check=1d20+{WisBonus}");
						line();
							a = attribute("Cha", "CHA", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Cha']" />", "char_attr");
							attach_attribute(attribute("ChaBonus", null, TYPE_label, "", "char_attr_bonus"), a.value_node, compute_bonus);
							stored_attributes["Cha"] = a;
						a = endline();
						add_die_roll(a,"Charisma Check=1d20+{ChaBonus}");
						line();
							a = attribute("Init", "Initiative Bonus", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Init']" />");
							add_die_roll(a, "Roll for Initiative!=1d20+{parseInt([Init]);}");
						endline();
					endblock();
					block_column("stats_tok");
						line();
							attribute("Token", null, TYPE_token, "<xsl:apply-templates select="character/attribute[@name='Token']" />");
						endline();
					endblock();
				endblock();
				line(); 
					attribute("AC", "AC", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='AC']" />", "line_3"); 
					attribute("Touch", "Touch", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Touch']" />", "line_3"); 
					attribute("FlatFooted", "FF", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='FlatFooted']" />", "line_3"); 
				endline();
				line(); 
					a = attribute("Fort", "FORT", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Fort']" />", "line_3");
					add_die_roll(a, "Fort Save=1d20+{parseInt([Fort]);}");
					a = attribute("Ref", "REF", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Ref']" />", "line_3");
					add_die_roll(a, "Ref Save=1d20+{parseInt([Ref]);}");
					a = attribute("Will", "WILL", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Will']" />", "line_3");
					add_die_roll(a, "Will Save=1d20+{parseInt([Will]);}");
				endline();
				line();
					attribute("MaxHP", "Max HP", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='MaxHP']" />", "line_2");
					attribute("DmgReduction", "DR", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='DmgReduction']" />", "line_2");
				endline();
				line();
					attribute("CurHP", "Current HP", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='MaxHP']" />", "basic2");
					attribute("NonlethalDamage", "Nonlethal", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='NonlethalDamage']" />", "basic2");
				endline();
				line();
					attribute("Conditions", "Conditional Modifiers", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Conditions']" />");
				endline();
			endblock();
		}
		
		function page_combat()
		{
			block_page("combat", "Combat");
				line();
					a = stored_attributes["BAB"] = attribute("BAB", "Base Attack Bonus: ", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='BAB']" />");
					add_die_roll(a, "Basic Attack=1d20+{parseInt([BAB]);}");
					a = stored_attributes["CMB"] = attribute("CMB", "Grapple/CMB", TYPE_label, "", "line_2");
					add_die_roll(a, "CMB=1d20+{parseInt([CMB]);}");
					a = stored_attributes["CMD"] = attribute("CMD", "CMD", TYPE_label, "", "line_2");
					attach_attribute(stored_attributes["CMB"], stored_attributes["BAB"].value_node, compute_cmb);
					attach_attribute(stored_attributes["CMB"], stored_attributes["Str"].value_node, compute_cmb);
					attach_attribute(stored_attributes["CMB"], stored_attributes["Size"].value_node, compute_cmb);
					attach_attribute(stored_attributes["CMD"], stored_attributes["BAB"].value_node, compute_cmd);
					attach_attribute(stored_attributes["CMD"], stored_attributes["Str"].value_node, compute_cmd);
					attach_attribute(stored_attributes["CMD"], stored_attributes["Dex"].value_node, compute_cmd);
					attach_attribute(stored_attributes["CMD"], stored_attributes["Size"].value_node, compute_cmd);
					
					attribute("Speed", "Speed", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Speed']" />", "line_1");
					endline();
				block_list("Attacks", "Attack", "Combat Attacks", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Attacks']" />
				endblock();
				block_list("Armor", "Armor", "Armor/Protection", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Armor']" />
				endblock();
			endblock();
		}
		
		function page_skills()
		{
			block_page("skills", "Abilities");
				block_list("Skills", "Skill", "Skills", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Skills']" />
				endblock();
				block_list("Feats", "StringList", "Feats", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Feats']" />
				endblock();
				block_list("Spells", "StringList", "Spells", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Spells']" />
				endblock();
				block_list("SpellCaps", "SpellCap", "Spell Capabilities", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap0']" />
						<xsl:with-param name="level" select="0" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap1']" />
						<xsl:with-param name="level" select="1" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap2']" />
						<xsl:with-param name="level" select="2" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap3']" />
						<xsl:with-param name="level" select="3" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap4']" />
						<xsl:with-param name="level" select="4" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap5']" />
						<xsl:with-param name="level" select="5" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap6']" />
						<xsl:with-param name="level" select="6" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap7']" />
						<xsl:with-param name="level" select="7" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap8']" />
						<xsl:with-param name="level" select="8" />
					</xsl:call-template>
					<xsl:call-template name="spell-cap">
						<xsl:with-param name="cap" select="character/attribute[@name='SpellCap9']" />
						<xsl:with-param name="level" select="9" />
					</xsl:call-template>
				a = endblock();
				a.add_node.parentNode.removeChild(a.add_node);
				a.add_node = null;
				
				block_list("Specials", "StringList", "Special Abilities", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Specials']" />
				endblock();
				block_list("Languages", "StringList", "Languages Known", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Languages']" />
				endblock();
			endblock();
		}
		
		function page_loot()
		{
			block_page("loot", "Stuff");
				attribute("Wealth", "Money", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Wealth']" />", "major_section");
				block_list("Equipment", "StringList", "Equipment", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Equipment']" />
				endblock();
			endblock();
		}
		
		function page_notes()
		{
			block_page("notes", "Notes");
				line();
					attribute("Align", "Alignment", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Align']" />", "line_2");
					attribute("Age", "Age", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Age']" />", "line_2");
				endline();
				line();
					attribute("Height", "Height", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Height']" />", "line_2");
					attribute("Weight", "Weight", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Weight']" />", "line_2");
				endline();
				line();
					attribute("Hair", "Hair", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Hair']" />", "line_2");
					attribute("Eyes", "Eyes", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Eyes']" />", "line_2");
				endline();
				line();
					attribute("Homeland", "Homeland", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Homeland']" />", "line_2");
					attribute("Deity", "Deity", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Deity']" />", "line_2");
				endline();
				attribute("Personality", "Personality", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Personality']" />", "major_section");
				attribute("Appearance", "Appearance", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Appearance']" />", "major_section");
				attribute("Background", "Background", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Background']" />", "major_section");
				attribute("Notes", "Notes", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Notes']" />", "major_section");
			endblock();
		}
	</xsl:template>
	
	<xsl:template match="attribute[@name='Attacks']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"bonus":"<xsl:value-of select="bonus" />",
				"damage":"<xsl:value-of select="damage" />",
				"critical":"<xsl:value-of select="critical" />",
				"range":"<xsl:value-of select="range" />",
				"type":"<xsl:value-of select="type" />",
				"notes":"<xsl:value-of select="notes" />",
				"ammo-type":"<xsl:value-of select="ammo-type" />",
				"ammo-count":"<xsl:value-of select="ammo-count" />"});
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="attribute[@name='Armor']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"type":"<xsl:value-of select="type" />",
				"ac-bonus":"<xsl:value-of select="ac-bonus" />",
				"max-dex":"<xsl:value-of select="max-dex" />",
				"check-penalty":"<xsl:value-of select="check-penalty" />",
				"spell-fail":"<xsl:value-of select="spell-fail" />",
				"weight":"<xsl:value-of select="weight" />",
				"properties":"<xsl:value-of select="properties" />"});
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="attribute[@name='Skills']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"bonus":"<xsl:value-of select="bonus" />",
				"attribute":"<xsl:value-of select="attribute" />",
				"class-skill":"<xsl:value-of select="class-skill" />"});
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="attribute[@name='Equipment']|attribute[@name='Feats']|attribute[@name='Languages']|attribute[@name='Specials']|attribute[@name='Spells']">
		<xsl:for-each select="item">
			list_item({"s":"<xsl:value-of select="." />"});
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="spell-cap">
		<xsl:param name="cap" />
		<xsl:param name="level" />
		item = list_item({
			"known":"<xsl:value-of select="$cap/known" />",
			"save-dc":"<xsl:value-of select="$cap/save-dc" />",
			"level":"<xsl:value-of select="$level" />",
			"per-day":"<xsl:value-of select="$cap/per-day" />",
			"bonus":"<xsl:value-of select="$cap/bonus" />"});
		item.id = "SpellCap<xsl:value-of select="$level" />";
	</xsl:template>

	<xsl:template match="attribute[@name='DieRolls']">
		<xsl:for-each select="item">
			{"name":"<xsl:value-of select="name" />",
			"roll":"<xsl:value-of select="roll" />"},
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>