<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template name="js_boilerplate">
		function compute_bonus(l,a)
		{
			var b = Math.floor(a.value / 2) - 5;
			if (b &gt; 0)
			l.value_node.innerText = "( +" + b + " )";
			else
			l.value_node.innerText = "( " + b + " )";
			eval(l.id + "=" + b);
		}
		function compute_bloodied(l,a)
		{
			var b = Math.max(Math.floor(a.value / 2), 0);
			l.value_node.innerText = b;
		}
		function compute_surge(l,a)
		{
			var b = Math.max(Math.floor(a.value / 4), 0);
			l.value_node.innerText = b;
		}
		var bgc = {"AtWill":"green", "Encounter":"red", "Daily":"black"};
		var txc = {"AtWill":"white", "Encounter":"white", "Daily":"white"};
		function color_power(p, t)
		{
			var typeName = t.value;
			p.style.backgroundColor = bgc[typeName];
			p.style.color = txc[typeName];
			p.value_node.style.backgroundColor = bgc[typeName];
			p.value_node.style.color = txc[typeName];
		}
		function hide_used(p, t)
		{
			var typeName = t.value;
			if (typeName == "AtWill")
			p.value_node.style.display = "none";
			else
			p.value_node.style.display = "inline-block";
		}

		function skill_die_notation(node)
		{
			return "[.name] Check=1d20+{parseInt(\"[.bonus]\")}";
		}

		function power_die_notation(node)
		{
			return "[.name]: Attack=1d20+{parseInt(\"[.attack-bonus]\")},Damage=[.damage-roll]";
		}

		tmpl = new list_template("Skill");
			tmpl.add_attribute("name", "Skill", TYPE_string, "", "line_p50");
			tmpl.add_attribute("bonus", "Bonus", TYPE_string, "", "line_p10");
			tmpl.add_attribute("trained", "Trn?", TYPE_bool, "false", "line_p20");
			tmpl.add_attribute("attribute", "Attr", TYPE_option, {"Str":"STR","Dex":"DEX","Con":"CON","Int":"INT","Wis":"WIS","Cha":"CHA"}, "line_p10");
			tmpl.post_construct = function(item)
			{
				add_die_roll(item,"{skill_die_notation(current_selection)}");
			}
		register_template(tmpl);

		tmpl = new list_template("Power");
			tmpl.collapse = true;
			tmpl.add_attribute("name", null, TYPE_string, "", "power_name");
			tmpl.add_attribute("use-type", "Usage", TYPE_option, {"AtWill":"At-Will","Encounter":"Encounter","Daily":"Daily"}, "line_2");
			tmpl.add_attribute("keywords", "Keywords", TYPE_string, "", "line_2");
			tmpl.add_attribute("action-type", "Action", TYPE_string, "Standard", "line_2");
			tmpl.add_attribute("category", "Type", TYPE_string, "Attack", "line_2");
			tmpl.add_attribute("target", "Target", TYPE_string, "", "line_2");
			tmpl.add_attribute("range", "Range", TYPE_string, "", "line_2");
			tmpl.add_attribute("effect", null, TYPE_text, "", "line_1");
			tmpl.add_attribute("used", null, TYPE_bool, "false", "power_used_check");
			tmpl.add_attribute("attack-bonus", "Attack: 1d20+", TYPE_int, "", "line_2");
			tmpl.add_attribute("damage-roll", "Damage Roll", TYPE_string, "", "line_2");

			tmpl.attach_attribute("name", "use-type", color_power);
			tmpl.attach_attribute("used", "use-type", hide_used);

			tmpl.post_construct = function(node)
			{
				node.remove_node.parentNode.removeChild(node.remove_node);
				var used = breadth_first_search(node, "used_container");
				var target = breadth_first_search(node, "name_container");
				if (target)
				{
					if (used)
					{
						used.parentNode.removeChild(used);
						target.attribute_node.appendChild(used);
					}
					target.attribute_node.appendChild(node.remove_node);
				}
				
				add_die_roll(node,"{power_die_notation(current_selection)}");
			}
		register_template(tmpl);

		function page_stats()
		{
			block_page("stats", "Stats");
				block_columns("stats_columns");
					block_column("stats_attribs");
						line(); 
							a = attribute("Str", "STR", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Str']" />", "char_attr"); 
							b = attribute("StrBonus", null, TYPE_label, "", "char_attr_bonus");
							attach_attribute(b, a.value_node, compute_bonus);
						a = endline();
						add_die_roll(a,"Strength Check=1d20+{StrBonus}");

						line();
							a = attribute("Dex", "DEX", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Dex']" />", "char_attr");
							b = attribute("DexBonus", null, TYPE_label, "", "char_attr_bonus");
							attach_attribute(b, a.value_node, compute_bonus);
						a = endline();
						add_die_roll(a,"Dexterity Check=1d20+{DexBonus}");

						line();
							a = attribute("Con", "CON", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Con']" />", "char_attr");
							b = attribute("ConBonus", null, TYPE_label, "", "char_attr_bonus");
							attach_attribute(b, a.value_node, compute_bonus);
						a = endline();
						add_die_roll(a,"Constitution Check=1d20+{ConBonus}");

						line();
							a = attribute("Int", "INT", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Int']" />", "char_attr");
							b = attribute("IntBonus", null, TYPE_label, "", "char_attr_bonus");
							attach_attribute(b, a.value_node, compute_bonus);
						a = endline();
						add_die_roll(a,"Intelligence Check=1d20+{IntBonus}");

						line();
							a = attribute("Wis", "WIS", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Wis']" />", "char_attr");
							b = attribute("WisBonus", null, TYPE_label, "", "char_attr_bonus");
							attach_attribute(b, a.value_node, compute_bonus);
						a = endline();
						add_die_roll(a,"Wisdom Check=1d20+{WisBonus}");

						line();
							a = attribute("Cha", "CHA", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Cha']" />", "char_attr");
							b = attribute("ChaBonus", null, TYPE_label, "", "char_attr_bonus");
							attach_attribute(b, a.value_node, compute_bonus);
						a = endline();
						add_die_roll(a,"Charisma Check=1d20+{ChaBonus}");

						line();
							attribute("AP", "Action Pts", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='AP']" />");
						endline();
					endblock();

					block_column("defenses");
						attribute("AC", "AC", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='AC']" />", "line_1"); 
						attribute("Fort", "FORT", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Fort']" />", "line_1");
						attribute("Ref", "REF", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Ref']" />", "line_1");
						attribute("Will", "WILL", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Will']" />", "line_1");
					endblock();

					block_column("stats_tok");
						line();
							attribute("Token", null, TYPE_token, "<xsl:apply-templates select="character/attribute[@name='Token']" />");
						endline();
						line();
							a = attribute("Init", "Initiative", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Init']" />");
							add_die_roll(a,"Roll for Initiative!=1d20+{Math.floor(GetAttributeValue('Init'))}");
							attribute("Speed", "Speed", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Speed']" />");
						endline();
					endblock();
				endblock();
				
				block_plain("hp_stats");
					attribute("__hp_section", "Hit Points", TYPE_label, "", "major_section");
					line();
						a = attribute("MaxHP", "Max HP", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='MaxHP']" />", "hp_4");
						attach_attribute(attribute("Bloodied", "Bloodied", TYPE_label, "", "hp_4"), a.value_node, compute_bloodied);
						attribute("Surges", "Surges", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Surges']" />", "hp_4");
						attach_attribute(attribute("SurgeVal", "Surge Value", TYPE_label, "", "hp_4"), a.value_node, compute_surge);
					endline();
					attribute("CurHP", "Current HP", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='MaxHP']" />", "line_1");
					attribute("CurSurges", "Surges Used", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='CurSurges']" />", "line_3");
					attribute("TempHP", "Temp HP", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='TempHP']" />", "line_3");
					a = attribute("DeathSave", "Death Saves", TYPE_slider, ["<xsl:apply-templates select="character/attribute[@name='DeathSave']" />",3], "line_3");
					add_die_roll(a,"Death Save=1d20");
					attribute("SecondWind", "Second Wind Used", TYPE_bool, "<xsl:apply-templates select="character/attribute[@name='SecondWind']" />", "footer_attr");
				endblock();
				block_plain("saves");
					attribute("SaveMods", "Saving Throw Mods", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='SaveMods']" />", "line_1");
					attribute("Resist", "Resistances", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Resist']" />", "line_1");
					line();
						attribute("Conditions", "Conditional Modifiers", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Conditions']" />");
						endline();
				endblock();
			endblock();
		}

		function page_powers()
		{
			block_page("powers", "Powers");
				block_list("Powers", "Power", "Powers", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Powers']" />
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
				block_list("Languages", "StringList", "Languages Known", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Languages']" />
				endblock();
				block_list("Rituals", "StringList", "Rituals", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='Rituals']" />
				endblock();
				block_list("RaceFeatures", "StringList", "Race Features", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='RaceFeatures']" />
				endblock();
				block_list("ClassFeatures", "StringList", "Class Features", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='ClassFeatures']" />
				endblock();
				block_list("ParagonFeatures", "StringList", "Paragon Path Features", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='ParagonFeatures']" />
				endblock();
				block_list("EpicFeatures", "StringList", "Epic Destiny Features", LISTSTYLE_rows, ITEMSTYLE_columns);
					<xsl:apply-templates select="character/attribute[@name='EpicFeatures']" />
				endblock();
			endblock();
		}

		function page_loot()
		{
			block_page("loot", "Loot");
				attribute("Wealth", "Wealth", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Wealth']" />", "major_section");
				block_list("Equipment", "StringList", "Equipment", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='Equipment']" />
				endblock();
				block_list("MagicItems", "StringList", "Magic Items", LISTSTYLE_rows, ITEMSTYLE_inline);
					<xsl:apply-templates select="character/attribute[@name='MagicItems']" />
				b = endblock();
				a = attribute("MIUsed", "Daily Item Powers Used", TYPE_slider, ["<xsl:apply-templates select="character/attribute[@name='MIUsed']" />",3]);
				a.parentNode.removeChild(a);
				b.content_node.parentNode.insertBefore(a, b.content_node);
			endblock();
		}

		function page_misc()
		{
			block_page("misc", "Misc");
				line();
					attribute("Player", "Player", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Player']" />", "line_1");
				endline();
				line();
					attribute("Align", "Alignment", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Align']" />", "line_2");
					attribute("Deity", "Deity", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Deity']" />", "line_2");
				endline();
				line();
					attribute("Age", "Age", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Age']" />", "line_4");
					attribute("Gender", "Gender", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Gender']" />", "line_4");
					attribute("Height", "Height", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Height']" />", "line_4");
					attribute("Weight", "Weight", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Weight']" />", "line_4");
				endline();
				line();
					attribute("Company", "Adventuring Company", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Company']" />", "line_1");
					attribute("Paragon", "Paragon Path", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Paragon']" />", "line_1");
					attribute("Epic", "Epic Destiny", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Epic']" />", "line_1");
					attribute("XP", "Total XP", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='XP']" />", "line_1");
				endline();
				attribute("Personality", "Personality", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Personality']" />", "major_section");
				attribute("Appearance", "Appearance", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Appearance']" />", "major_section");
				attribute("Background", "Background", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Background']" />", "major_section");
				attribute("Allies", "Companions and Allies", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Allies']" />", "major_section");
				attribute("Notes", "Session and Campaign Notes", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Notes']" />", "major_section tall_text");
			endblock();
		}
	</xsl:template>
	<xsl:template match="attribute[@name='Powers']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"keywords":"<xsl:value-of select="keywords" />",
				"use-type":"<xsl:value-of select="use-type" />",
				"action-type":"<xsl:value-of select="action-type" />",
				"category":"<xsl:value-of select="category" />",
				"target":"<xsl:value-of select="target" />",
				"range":"<xsl:value-of select="range" />",
				"effect":"<xsl:value-of select="effect" />",
				"used":"<xsl:value-of select="used" />",
				"attack-bonus":"<xsl:value-of select="attack-bonus" />",
				"damage-roll":"<xsl:value-of select="damage-roll" />"});
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="attribute[@name='Skills']">
		<xsl:for-each select="item">
			list_item({
				"name":"<xsl:value-of select="name" />",
				"bonus":"<xsl:value-of select="bonus" />",
				"trained":"<xsl:value-of select="trained" />",
				"attribute":"<xsl:value-of select="attribute" />"});
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="attribute[@name='Equipment']|attribute[@name='Rituals']|attribute[@name='MagicItems']|attribute[@name='Feats']|attribute[@name='Languages']|attribute[@name='EpicFeatures']|attribute[@name='ParagonFeatures']|attribute[@name='ClassFeatures']|attribute[@name='RaceFeatures']">
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