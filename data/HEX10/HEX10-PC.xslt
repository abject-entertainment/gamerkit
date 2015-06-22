<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:template name="js_boilerplate">
		var skills_list = null;
	
		var super_GetAttributeNode = GetAttributeNode;
		GetAttributeNode = function(path)
		{
			if (path.substr(0,15) == "Specializations")
			{
				// can only be "Specializations[idx].sub_attr"
				var mark = path.indexOf("]");
				var idx = path.substring(16,mark);
				var sub_attr = path.substring(mark+2);
				
				var skill_list = skills_list.content_node.firstChild;
				
				while (skill_list)
				{
					if (skill_list.block_type == BLOCK_listitem)
					{
						spec_list = skill_list.spec_list.content_node.firstChild;
						
						while (spec_list)
						{
							if (spec_list.block_type == BLOCK_listitem)
							{
								if (idx == 0)
								{
									return spec_list.attrs[sub_attr].attribute_node.value_node;
								}
								--idx;
							}
							spec_list = spec_list.nextSibling;
						}
					}
					skill_list = skill_list.nextSibling;
				}
				return "[[outofbounds]]";
			}
			else
			{
				return super_GetAttributeNode(path);
			}
		}
		
		function spec_update_ranks(i,a)
		{
			var ranks = Math.floor(ValueFromNode(i.attrs["ranks"].attribute_node.value_node)) + 
				Math.floor(ValueFromNode(i.list_block.skill_item.attrs["rating"].attribute_node.value_node));
			
			i.attrs["rating"].attribute_node.value_node.innerText = ranks;
			
			var plus = (ranks%2)?"+":"";
			ranks = Math.floor(ranks/2);
			
			i.attrs["average"].attribute_node.value_node.innerText = "(" + ranks + plus + ")";
		}
		function spec_post_construct(item)
		{
			item.skill_item = item.list_block.skill_item;
			attach_attribute(item, item.attrs["ranks"].attribute_node.value_node, spec_update_ranks);
			add_die_roll(item, "/i/[.name]=[.rating]d2-[.rating]=Successes");
		}
		tmpl = new list_template("specialization");
			tmpl.add_attribute("name", null, TYPE_string, "", "spec_name");
			tmpl.add_attribute("skill", null, TYPE_label, "", "spec_skill");
			tmpl.add_attribute("ranks", null, TYPE_int, "0", "");
			tmpl.add_attribute("rating", null, TYPE_label, "", "");
			tmpl.add_attribute("average", null, TYPE_label, "", "");
			tmpl.collapse = false;
			tmpl.post_construct = spec_post_construct;
		register_template(tmpl);

		function skill_update_base(l,a)
		{
			l.value_node.innerText = Math.floor(ValueFromNode(cached_attributes[ValueFromNode(a)].value_node));
		}
		function skill_update_ranks(i,a)
		{
			var rate = Math.floor(ValueFromNode(i.attrs["base"].attribute_node.value_node)) +
					   Math.floor(ValueFromNode(i.attrs["ranks"].attribute_node.value_node));
					   
			i.attrs["rating"].attribute_node.value_node.innerText = rate;
			var plus = (rate % 2)?"+":"";
			rate = Math.floor(rate/2);
			i.attrs["average"].attribute_node.value_node.innerText = "(" + rate + plus + ")";
			
			var spec = i.spec_list.content_node.firstChild;
			
			while (spec)
			{
				if (spec.block_type == BLOCK_listitem)
				{
					spec_update_ranks(spec,null);
				}
				spec = spec.nextSibling;
			}
		}
		function skill_update_name(l,a)
		{
			var sname = ValueFromNode(a);
			
			var node = l.content_node.firstChild;
			
			while (node)
			{
				if (node.block_type &amp;&amp; node.block_type == BLOCK_listitem)
				{
					node.attrs["skill"].attribute_node.value_node.innerText = sname;
				}
				node = node.nextSibling;
			}
		}
		function skill_post_construct(item)
		{
			// handler for updating base attribute
			item.attrs["base"].attribute_node.attr_selection = item.attrs["attribute"].attribute_node.value_node;
			item.attrs["base"].attribute_node.handle_click = function(e) { this.attr_selection.focus(); }
			item.attrs["base"].attribute_node.setAttribute("onclick", "javascript:this.handle_click()");
			
			var tempblock = current_block;
			current_block = item;
			block_list("specs", "specialization", null, LISTSTYLE_rows, ITEMSTYLE_columns);
			item.spec_list = endblock();
			item.spec_list.skill_item = item;
			current_block = tempblock;
			
			var spec = item.spec_list.add_node;
			spec.className = "specialize_button";
			spec.setAttribute("onclick", "javascript:this.handle_click()");
			spec.innerText = "+Sp";
			item.attrs["name"].appendChild(spec);
			spec.super_click = spec.handle_click;
			spec.handle_click = function()
			{
				var tmpl = templates["specialization"];
				var skill_attr = null;
				for (i = 0; i &lt; tmpl.attributes.length; ++i)
				{
					if (tmpl.attributes[i].attribute_name == "skill")
					{
						skill_attr = tmpl.attributes[i];
					}
				}
				
				var temp_skill = skill_attr.default_value;
				skill_attr.default_value = ValueFromNode(item.attrs["name"].attribute_node.value_node);
				var new_item = spec.super_click();
				new_item.skill_item = this.skill_item;
				skill_attr.default_value = temp_skill;
			}
			item.attrs["name"].appendChild(spec);
			attach_attribute(item.spec_list, item.attrs["name"].attribute_node.value_node, skill_update_name);

			item.remove_node.parentNode.removeChild(item.remove_node);
			item.attrs["name"].appendChild(item.remove_node);

			// attachments for base score selection from attribute and ranks/average calculation
			attach_attribute(item.attrs["base"].attribute_node, item.attrs["attribute"].attribute_node.value_node, skill_update_base);
			attach_attribute(item, item.attrs["attribute"].attribute_node.value_node, skill_update_ranks);
			attach_attribute(item, item.attrs["ranks"].attribute_node.value_node, skill_update_ranks);
			
			add_die_roll(item, "/i/[.name]=[.rating]d2-[.rating]=Successes");
		}
		
		tmpl = new list_template("skill");
			tmpl.add_attribute("name", null, TYPE_string, "", "");
			tmpl.add_attribute("attribute", null, TYPE_option, {"Body":"Body","Dexterity":"Dexterity","Strength":"Strength","Charisma":"Charisma","Intelligence":"Intelligence","Willpower":"Willpower"}, "skill_attr_option");
			tmpl.add_attribute("base", "Base", TYPE_label, "", "");
			tmpl.add_attribute("ranks", "Levels", TYPE_int, "0", "");
			tmpl.add_attribute("rating", "Rating", TYPE_label, "", "");
			tmpl.add_attribute("average", "Avg", TYPE_label, "", "");
			
			tmpl.post_construct = skill_post_construct;
			tmpl.collapse = false;
		register_template(tmpl);

		function weapon_update_average(l,a)
		{
			var avg = Math.floor(ValueFromNode(a));
			var plus = (avg % 2)?"+":"";
			avg = Math.floor(avg/2);
			l.value_node.innerText = "(" + avg + plus + ")";
		}
		function weapon_post_construct(item)
		{
			var children = ["damage_nl", "attack_nl", "average_nl"];
			var handle_click = function (e)
			{
				var lethal = ValueFromNode(this.list_item.attrs["lethal"].attribute_node.value_node);
				
				if (lethal == "true")
				{
					this.list_item.attrs["damage_nl"].attribute_node.value_node.innerText = "N";
					this.list_item.attrs["attack_nl"].attribute_node.value_node.innerText = "N";
					this.list_item.attrs["average_nl"].attribute_node.value_node.innerText = "N";
					this.list_item.attrs["lethal"].attribute_node.value_node.checked = false;
				}
				else
				{
					this.list_item.attrs["damage_nl"].attribute_node.value_node.innerText = "L";
					this.list_item.attrs["attack_nl"].attribute_node.value_node.innerText = "L";
					this.list_item.attrs["average_nl"].attribute_node.value_node.innerText = "L";
					this.list_item.attrs["lethal"].attribute_node.value_node.checked = true;
				}
			}
			
			for (i = 0; i &lt; children.length; ++i)
			{
				item.attrs[children[i]].list_item = item;
				item.attrs[children[i]].handle_click = handle_click;
				item.attrs[children[i]].setAttribute("onclick", "javascript:this.handle_click()");
			}
			
			attach_attribute(item.attrs["average"].attribute_node, item.attrs["attack"].attribute_node.value_node, weapon_update_average);
			
			item.remove_node.parentNode.removeChild(item.remove_node);
			item.attrs["name"].appendChild(item.remove_node);
			
			item.collapse_node.parentNode.removeChild(item.collapse_node);
			item.expand_node.parentNode.removeChild(item.expand_node);
			
			item.insertBefore(item.collapse_node, item.attrs["lethal"]);
			item.insertBefore(item.expand_node, item.attrs["lethal"]);

			add_die_roll(item, "/i/[.name]=[.attack]d2-[.attack]=Successes");
		}
		
		tmpl = new list_template("weapon");
			tmpl.add_attribute("name", null, TYPE_string, "", "");
			tmpl.add_attribute("lethal", null, TYPE_bool, "", "");
			tmpl.add_attribute("damage", "Rating", TYPE_string, "", "");
			tmpl.add_attribute("damage_nl", null, TYPE_label, "", "weap_lethal_tag");
			tmpl.add_attribute("modifier", "Size", TYPE_string, "", "");
			tmpl.add_attribute("attack", "Attack", TYPE_string, "", "");
			tmpl.add_attribute("attack_nl", null, TYPE_label, "", "weap_lethal_tag");
			tmpl.add_attribute("average", "Average", TYPE_label, "", "");
			tmpl.add_attribute("average_nl", null, TYPE_label, "", "weap_lethal_tag");
			
			tmpl.add_attribute("range", "Range", TYPE_string, "", "line_2");
			tmpl.add_attribute("capacity", "Capacity", TYPE_string, "", "line_2");
			tmpl.add_attribute("rate", "Rate", TYPE_string, "", "line_2");
			tmpl.add_attribute("speed", "Speed", TYPE_string, "", "line_2");
			tmpl.add_attribute("weight", "Weight", TYPE_string, "", "line_2");
			tmpl.add_attribute("ammo", "Ammo", TYPE_string, "", "line_2");
			tmpl.add_attribute("notes", "Notes", TYPE_text, "", "line_1");
			
			tmpl.post_construct = weapon_post_construct;
			tmpl.collapse = 8;
		register_template(tmpl);

		var cached_attributes = new Array;
		var all_cached = false;
		
		function update_secondaries(l,a)
		{
			if (all_cached)
			{
				cached_attributes["Move"].value_node.innerText = 
					Math.floor(ValueFromNode(cached_attributes["Strength"].value_node)) +
					Math.floor(ValueFromNode(cached_attributes["Dexterity"].value_node));
				cached_attributes["Perception"].value_node.innerText = 
					Math.floor(ValueFromNode(cached_attributes["Intelligence"].value_node)) +
					Math.floor(ValueFromNode(cached_attributes["Willpower"].value_node));
				cached_attributes["Initiative"].value_node.innerText = 
					Math.floor(ValueFromNode(cached_attributes["Dexterity"].value_node)) +
					Math.floor(ValueFromNode(cached_attributes["Intelligence"].value_node));
				cached_attributes["Defense"].value_node.innerText = 
					Math.floor(ValueFromNode(cached_attributes["Body"].value_node)) +
					Math.floor(ValueFromNode(cached_attributes["Dexterity"].value_node)) -
					Math.floor(ValueFromNode(cached_attributes["Size"].value_node));
				cached_attributes["Stun"].value_node.innerText = 
					Math.floor(ValueFromNode(cached_attributes["Body"].value_node));
				cached_attributes["MaxHealth"].value_node.innerText = " / " +
					(Math.floor(ValueFromNode(cached_attributes["Body"].value_node)) +
					Math.floor(ValueFromNode(cached_attributes["Willpower"].value_node)) +
					Math.floor(ValueFromNode(cached_attributes["Size"].value_node)));
			}
		}
		
		function page_stats()
		{
			attribute("lbl_pri", "Primary Attributes", TYPE_label, "", "major_section");
			
			a = attribute("Body", "Body", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Body']" />", "line_2");
			attach_attribute(a,a.value_node,update_secondaries);
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Charisma", "Charisma", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Charisma']" />", "line_2");
			attach_attribute(a,a.value_node,update_secondaries);
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Dexterity", "Dexterity", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Dexterity']" />", "line_2");
			attach_attribute(a,a.value_node,update_secondaries);
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Intelligence", "Intelligence", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Intelligence']" />", "line_2");
			attach_attribute(a,a.value_node,update_secondaries);
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Strength", "Strength", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Strength']" />", "line_2");
			attach_attribute(a,a.value_node,update_secondaries);
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Willpower", "Willpower", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Willpower']" />", "line_2");
			attach_attribute(a,a.value_node,update_secondaries);
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			attribute("lbl_pri", "Secondary Attributes", TYPE_label, "", "major_section");
			
			a = attribute("Size", "Size", TYPE_int, "<xsl:apply-templates select="character/attribute[@name='Size']" />", "line_2");
			attach_attribute(a,a.value_node,update_secondaries);
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Initiative", "Initiative", TYPE_label, "<xsl:apply-templates select="character/attribute[@name='Initiative']" />", "line_2");
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Move", "Move", TYPE_label, "<xsl:apply-templates select="character/attribute[@name='Move']" />", "line_2");
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Defense", "Defense", TYPE_label, "<xsl:apply-templates select="character/attribute[@name='Defense']" />", "line_2");
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Perception", "Perception", TYPE_label, "<xsl:apply-templates select="character/attribute[@name='Perception']" />", "line_2");
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			a = attribute("Stun", "Stun", TYPE_label, "<xsl:apply-templates select="character/attribute[@name='Stun']" />", "line_2");
			cached_attributes[a.id] = a;
			add_die_roll(a, "/i/" + a.id + "=[" + a.id + "]d2-[" + a.id + "]=Successes");
			
			all_cached = true;
			update_secondaries(null,null);
			
			block_list("Skills", "skill", "Skills", LISTSTYLE_rows, ITEMSTYLE_columns);
				<xsl:apply-templates select="character/attribute[@name='Skills']" />
			skills_list = endblock();

			block_list("Weapons", "weapon", "Weapons", LISTSTYLE_rows, ITEMSTYLE_columns);
				<xsl:apply-templates select="character/attribute[@name='Weapons']" />
			endblock();
		}
		
		function page_info()
		{
			attribute("Player", "Player", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Player']" />", "line_1");
			attribute("Campaign", "Campaign", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Campaign']" />", "line_1");
			attribute("Experience", "Experience", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Experience']" />", "line_1");
			attribute("Age", "Age", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Age']" />", "line_3");
			attribute("Gender", "Gender", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Gender']" />", "line_3");
			attribute("Height", "Height", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Height']" />", "line_3");
			attribute("Eyes", "Eyes", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Eyes']" />", "line_3");
			attribute("Hair", "Hair", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Hair']" />", "line_3");
			attribute("Skin", "Skin", TYPE_string, "<xsl:apply-templates select="character/attribute[@name='Skin']" />", "line_3");
			
			block_columns("cols_wealth_token");
				block_column("col_wealth");
					attribute("Wealth", "Wealth", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Wealth']" />", "major_section line_1");
				endblock();
				block_column("col_token");
					attribute("Token", null, TYPE_token, "<xsl:apply-templates select="character/attribute[@name='Token']" />");
				endblock();
			endblock();
			
			block_list("Equipment", "StringList", "Equipment", LISTSTYLE_rows, ITEMSTYLE_inline);
				<xsl:apply-templates select="character/attribute[@name='Equipment']" />
			endblock();
			block_list("Languages", "StringList", "Languages", LISTSTYLE_rows, ITEMSTYLE_inline);
				<xsl:apply-templates select="character/attribute[@name='Languages']" />
			endblock();

			attribute("Background", "Background", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Background']" />", "major_section");
			attribute("Notes", "Notes", TYPE_text, "<xsl:apply-templates select="character/attribute[@name='Notes']" />", "major_section");
		}
		
		function add_specs()
		{
			var specs = new Object;
			var sk = null;
			
			<xsl:apply-templates select="character/attribute[@name='Specializations']" />
			
			if (skills_list)
			{
				var skill_item = skills_list.content_node.firstChild;
				while (skill_item)
				{
					if (skill_item.block_type == BLOCK_listitem)
					{
						var items = specs[ValueFromNode(skill_item.attrs["name"].attribute_node.value_node)];
						if (items &amp;&amp; skill_item.spec_list)
						{
							var cached_block = current_block;
							current_block = skill_item.spec_list;
							for (i = 0; i &lt; items.length; ++i)
							{
								list_item(items[i]);
							}
							current_block = cached_block;
						}
					}
					skill_item = skill_item.nextSibling;
				}
			}
		}
		
		function debug_test()
		{
			// debug tests
			if (debug)
			{
				var tests = [
					"Name",
					"Skills[1].ranks",
					"Specializations[0].name",
					"Weapons[2].range",
					"Experience",
					"Skills[2].name"
					];
					
				for (i = 0; i &lt; tests.length; ++i)
				{
					dbgOut.writeln("!! " + tests[i] + " == " + GetAttributeValue(tests[i]));
				}
			}
		}
	</xsl:template>
	
	<xsl:template match="attribute[@name='Specializations']">
		<xsl:for-each select="item">
			sk = "<xsl:value-of select="skill" />";
			if (specs[sk] == null) specs[sk] = new Array();
			specs[sk].push({
				name:"<xsl:value-of select="name" />",
				skill:sk,
				ranks:"<xsl:value-of select="ranks" />"});
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="attribute[@name='Skills']">
		<xsl:for-each select="item">
			a = list_item({
				"name":"<xsl:value-of select="name" />",
				"attribute":"<xsl:value-of select="attribute" />",
				"ranks":"<xsl:value-of select="ranks" />"});
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="attribute[@name='Weapons']">
		<xsl:for-each select="item">
			a = list_item({
				"name":"<xsl:value-of select="name" />",
				"lethal":"<xsl:value-of select="lethal" />",
				"damage":"<xsl:value-of select="damage" />",
				"modifier":"<xsl:value-of select="modifier" />",
				"attack":"<xsl:value-of select="attack" />",
				"range":"<xsl:value-of select="range" />",
				"capacity":"<xsl:value-of select="capacity" />",
				"rate":"<xsl:value-of select="rate" />",
				"speed":"<xsl:value-of select="speed" />",
				"weight":"<xsl:value-of select="weight" />",
				"ammo":"<xsl:value-of select="ammo" />",
				"notes":"<xsl:value-of select="notes" />"});
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="attribute[@name='Talents']|attribute[@name='Resources']|attribute[@name='Flaws']|attribute[@name='Equipment']|attribute[@name='Languages']">
		<xsl:for-each select="item">
			list_item({"s":"<xsl:value-of select="." />"});
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>