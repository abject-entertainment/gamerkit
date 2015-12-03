var debug = false;

var dbgOut = new Object();
dbgOut.write = function(txt) {};
dbgOut.writeln = function(txt) {};

if (debug)
{
	dbgOut = document.createElement("DIV");
	dbgOut.id = "debug_text";
	document.body.appendChild(dbgOut);

	dbgOut.spew = document.createElement("DIV");
	dbgOut.spew.id = "debug_output";
	dbgOut.appendChild(dbgOut.spew);
	
	var input = document.createElement("INPUT");
	input.setAttribute("type","text");
	input.id = "debug_input";
	input.handle_key = function(event)
	{
		if (event.which == 13)
		{
			event.preventDefault();
			eval(this.value);
		}
	}
	input.onkeyup = input.handle_key;
	dbgOut.appendChild(input);
	
	var buttons = [
		{ t:"Shake", c:"HandleShake()" }
	];
	
	for (var i = 0; i < buttons.length; ++i)
	{
		var btn = document.createElement("INPUT");
		btn.setAttribute("type","button");
		btn.setAttribute("value", buttons[i].t);
		btn.setAttribute("onclick", buttons[i].c);
		dbgOut.appendChild(btn);
	}
		
	dbgOut.write = function (txt)
	{
		this.spew.innerText += txt;
	}
	
	dbgOut.writeln = function(txt)
	{
		this.write(txt + "\n");
	}
}

const TYPE_int = 0;
const TYPE_string = 1; // single-line text
const TYPE_bool = 2;
const TYPE_option = 3;
const TYPE_text = 4; // multi-line text
const TYPE_token = 5;
const TYPE_label = 6; // non-editable
const TYPE_slider = 7;

const LISTSTYLE_inline = "inline";
const LISTSTYLE_rows = "rows";

const ITEMSTYLE_inline = "inline";
const ITEMSTYLE_columns = "columns";

const BLOCK_plain="plain";
const BLOCK_columns="columns";
const BLOCK_column="column";
const BLOCK_pages="pages";
const BLOCK_page="page";
const BLOCK_table="table";
const BLOCK_list="list";
const BLOCK_listitem="item";
const BLOCK_line="line";


// templates - For adding new list items to a section
var templates = new Array();

function list_attribute(attr_name, label_text, value_type, value_default, extra_class)
{
	this.attribute_name = attr_name;
	this.label_text = label_text;
	this.value_type = value_type;
	this.default_value = value_default;
	this.extra_class = extra_class;
	
	this.construct = function(with_value, list_type, item_type)
	{
		var node = document.createElement("DIV");
		node.className = item_type + "_item";
		if (this.extra_class) node.className = node.className + " " + this.extra_class;
		node.id = this.attribute_name + "_container";
		
		//node.block_type = BLOCK_listitem;
		node.block_name = current_block.id;
		
		var block_cache = current_block;
		current_block = node;
		
		var temp_value;
		if (with_value)
		{
			if (this.value_type == TYPE_option)
			{
				temp_value = this.default_value["attr_value"];
				this.default_value["attr_value"] = with_value;
				with_value = this.default_value;
			}
		}
		else
		{
			if (this.value_type == TYPE_option)
			{
				temp_value = this.default_value["attr_value"];
				with_value = this.default_value;
			}
			else
			{
				with_value = this.default_value;
			}
		}			
		
		node.attribute_node = attribute(this.attribute_name, (item_type==ITEMSTYLE_inline)?this.label_text:null, this.value_type, with_value);
		
		if (this.value_type == TYPE_option)
		{
			this.default_value["attr_value"] = temp_value;
		}
		
		current_block = block_cache;
		
		return node;
	}
	
	return this;
}

function list_template(type_name)
{
	this.template_name = type_name;
	this.collapse = false;
	this.start_collapsed = true;
	this.attributes = new Array();
	this.attachments = new Array();
	this.post_construct = null;
	
	this.add_attribute = function (attr_name, label_text, value_type, value_default, extra_class)
	{
		var new_attr = new list_attribute(attr_name, label_text, value_type, value_default, extra_class);
		new_attr.list_template = this;
		this.attributes[this.attributes.length] = new_attr;
	}
	
	this.attach_attribute = function(attacher, attachee, fn)
	{
		if (this.attachments[attachee] == undefined)
		{
			this.attachments[attachee] = new Array();
		}
		
		this.attachments[attachee].push({ obj:attacher, fn:fn });
	}
	
	this.construct = function (list_block, attr_values, list_type, item_type)
	{
		var node = document.createElement("DIV");
		node.className = this.template_name + "_listitem " + list_type + "_list";
		node.block_type = BLOCK_listitem;
		node.list_block = list_block;
		
		var nodes = new Array();
		var insert_node = node;
		for (var i = 0; i < this.attributes.length; ++i)
		{
			var val = attr_values?attr_values[this.attributes[i].attribute_name]:null;
			var anode = this.attributes[i].construct(val, list_type, ((this.collapse >= 0) && (i > this.collapse))?ITEMSTYLE_inline:item_type);
			
			insert_node.appendChild(anode);
			nodes[this.attributes[i].attribute_name] = anode;
			
			if (i == this.collapse)
			{
				node.collapse_node = document.createElement("DIV");
				node.collapse_node.className = this.template_name + "_item_collapse list_item_collapse";
				
				node.expand_node = document.createElement("DIV");
				node.expand_node.className = this.template_name + "_item_expand list_item_expand";
				
				node.collapse_block = document.createElement("DIV");
				
				node.collapse_node.collapse_block = node.collapse_block;
				node.expand_node.collapse_block = node.collapse_block;
				node.collapse_node.expand_node = node.expand_node;
				node.expand_node.collapse_node = node.collapse_node;
				
				node.collapse_node.handle_click = function()
				{
					this.style.display = "none";
					this.expand_node.style.display = "inline-block";
					this.collapse_block.style.display = "none";
				}
				node.collapse_node.setAttribute("onclick", "javascript:this.handle_click()");
				
				node.expand_node.handle_click = function()
				{
					this.style.display = "none";
					this.collapse_node.style.display = "inline-block";
					this.collapse_block.style.display = "inline-block";
				}
				node.expand_node.setAttribute("onclick", "javascript:this.handle_click()");
				
//				insert_node.appendChild(node.collapse_node);
//				insert_node.appendChild(node.expand_node);
				anode.attribute_node.insertBefore(node.collapse_node, anode.attribute_node.firstChild);
				anode.attribute_node.insertBefore(node.expand_node, anode.attribute_node.firstChild);
				
				insert_node.appendChild(node.collapse_block);
				insert_node = node.collapse_block;
				
			}
		}
		
		for (var i = 0; i < this.attributes.length; ++i)
		{
			var attachments = this.attachments[this.attributes[i].attribute_name];
			var attach_node = nodes[this.attributes[i].attribute_name]
			if (attachments && attach_node)
			{
				for (var j = 0; j < attachments.length; ++j)
				{
					var attacher = attachments[j].obj;
					if (typeof(attacher) == "string")
					{
						attacher = nodes[attacher];
					}
					
					if (attacher)
					{
						attach_attribute(attacher.attribute_node, attach_node.attribute_node.value_node, attachments[j].fn);
					}
				}
			}
		}	
		
		var remove_node = document.createElement("DIV");
		remove_node.className = this.template_name + "_remove_button remove_button";
		remove_node.parent_node = node;
		remove_node.handle_click = function ()
		{
			if (window.confirm("Are you sure you want to remove this item?"))
			{
				this.parent_node.parentNode.removeChild(this.parent_node);
			}
		}
		remove_node.setAttribute("onclick", "javascript:this.handle_click()");
		node.appendChild(remove_node);
		node.remove_node = remove_node;
		
		node.attrs = nodes;
		
		if (this.post_construct)
		{
			this.post_construct(node);
		}
		
		if (this.start_collapsed && node.collapse_node)
		{
			node.collapse_node.handle_click();
		}
		return node;
	}
	
	return this;
}

function register_template(templ)
{
	if (typeof tmpl.collapse == "boolean")
	{
		tmpl.collapse = tmpl.collapse?0:-1;
	}
	
	templates[templ.template_name] = templ;
}

// layout - For defining the sheet layout elements
var current_block = null;

function push_block(block_node, bl_type)
{
	block_node.block_type = bl_type;
	block_node.parent_block = current_block;
	if (block_node.child_blocks == null)
		block_node.child_blocks = new Array();
	if (current_block) 
	{
		if (current_block.child_blocks == null)
			current_block.child_blocks = new Array();
			
		current_block.child_blocks[current_block.child_blocks.length] = block_node;
	}
	current_block = block_node;
}

function block_plain(block_name)
{
	var node = document.createElement("DIV");
	node.className = "block_plain";
	node.id = block_name;
	
	push_block(node, BLOCK_plain);
}

function block_columns(block_name)
{
	var node = document.createElement("DIV");
	node.className = "block_columns";
	node.id = block_name;
	
	push_block(node, BLOCK_columns);
}

function block_column(block_name)
{
	var node = document.createElement("DIV");
	node.className = "block_column";
	node.id = block_name;
	
	push_block(node, BLOCK_column);
}

function block_table(block_name)
{
	var node = document.createElement("TABLE");
	node.className = "block_table";
	node.id = block_name;
	
	push_block(node, BLOCK_table);
}

function block_pages(block_name)
{
	var node = document.createElement("DIV");
	node.className = "block_pages";
	node.id = block_name;
	
	node.tab_list = new Array();
	node.select_tab = function (tab_index)
	{
		if (tab_index >= 0 && this.tab_list.length > tab_index)
		{
			this.tab_list[tab_index].handle_click();
		}
	}
	
	node.add_tab = function (new_tab, tab_page)
	{
		if (new_tab)
		{
			this.tab_bar.appendChild(new_tab);
			
			new_tab.tab_page = tab_page;
			new_tab.tab_bar = this;
			new_tab.class_base = new_tab.className;
			new_tab.className = new_tab.class_base + " tab_inactive";
			
			new_tab.handle_click = function ()
			{
				if (this.tab_bar)
				{
					for (var i = 0; i < this.tab_bar.tab_list.length; ++i)
					{
						var tab = this.tab_bar.tab_list[i];
						
						if (tab == this)
						{
							if (tab.tab_page)
							{
								tab.tab_page.style.display = "block";
								tab.className = tab.class_base + " tab_active";
							}
						}
						else
						{
							if (tab.tab_page)
							{
								tab.tab_page.style.display = "none";
								tab.className = tab.class_base + " tab_inactive";
							}
						}
					}
				}
			}
			new_tab.setAttribute("onclick", "javascript:this.handle_click()");
			
			this.tab_list[this.tab_list.length] = new_tab;
			
			var width = 100.0 / this.tab_list.length;
			
			for (var i = 0; i < this.tab_list.length; ++i)
			{
				this.tab_list[i].style.width = (width.toString() + "%");
			}
		}
	}
	
	// set up tabs across the top
	node.tab_bar = document.createElement("DIV");
	node.tab_bar.className = block_name + "_tabs tab_bar";
	node.appendChild(node.tab_bar);
	
	push_block(node, BLOCK_pages);
}

function block_page(page_name, display_name)
{
	if (current_block != null && current_block.block_type == "pages")
	{
		var tab = document.createElement("DIV");
		tab.className = "page_tab";
		tab.id = page_name + "_tab";
		tab.innerText = display_name;
		
		var pg = document.createElement("DIV");
		pg.className = "block_page";
		pg.id = page_name;
		
		current_block.add_tab(tab, pg);
		
		push_block(pg, BLOCK_page);
	}
}

function block_list(list_name, list_template, display_name, list_style, item_style)
{
	var node = document.createElement("DIV");
	node.className = "block_list list_" + list_style;
	node.id = list_name;
	
	node.template_name = list_template;
	node.list_style = list_style;
	node.item_style = item_style;
	
	var content_node = document.createElement("DIV");
	content_node.className = "list_content";
	content_node.id = list_name + "_content";
	node.content_node = content_node;
	
	if (display_name)
	{
		var lbl_node = document.createElement("DIV");
		lbl_node.className = "list_label";
		lbl_node.id = list_name + "_list_label";
		lbl_node.innerHTML = display_name;
		node.appendChild(lbl_node);
		
		var expand_node = document.createElement("DIV");
		expand_node.className = "list_expand";
		expand_node.id = list_name + "_expand";
		
		node.expand_node = expand_node;
		
		var collapse_node = document.createElement("DIV");
		collapse_node.className = "list_collapse";
		collapse_node.id = list_name + "_collapse";
		
		node.collapse_node = collapse_node;
		
		collapse_node.expand_node = expand_node;
		expand_node.collapse_node = collapse_node;
		collapse_node.content_node = content_node;
		expand_node.content_node = content_node;
		
		expand_node.handle_click = function()
		{
			this.collapse_node.style.display = "inline-block";
			this.style.display = "none";
			this.content_node.style.display = "block";
		}
		collapse_node.handle_click = function()
		{
			this.expand_node.style.display = "inline-block";
			this.style.display = "none";
			this.content_node.style.display = "none";
		}
		expand_node.setAttribute("onclick", "javascript:this.handle_click()");
		collapse_node.setAttribute("onclick", "javascript:this.handle_click()");
		
		lbl_node.appendChild(collapse_node);
		lbl_node.appendChild(expand_node);
	}
	
	node.appendChild(content_node);
	
	if (item_style == ITEMSTYLE_columns)
	{
		var tmpl = templates[list_template];
		
		// add column headers
		var header_node = document.createElement("DIV");
		header_node.className = list_template + "_header list_header";
		
		for (var c = 0; c < tmpl.attributes.length && (tmpl.collapse < 0 || c <= tmpl.collapse); ++c)
		{
			var column_node = document.createElement("DIV");
			column_node.className = templates[list_template].attributes[c].attribute_name + "_column_header column_header";
			column_node.innerText = templates[list_template].attributes[c].label_text;
			
			header_node.appendChild(column_node);
		}
		content_node.appendChild(header_node);
	}
	
	var add_node = document.createElement("DIV");
	add_node.list_node = node;
	add_node.className = list_name + "_add_button add_button";
	add_node.handle_click = function ()
	{
		var tmpl = templates[this.list_node.template_name];
		
		if (tmpl)
		{
			var save_collapse = tmpl.start_collapsed;
			tmpl.start_collapsed = false;
			
			var block_cache = current_block;
			current_block = this.list_node;
			var new_item = tmpl.construct(this.list_node, null, this.list_node.list_style, this.list_node.item_style);
			
			if (this.parentNode == this.list_node.content_node)
				this.list_node.content_node.insertBefore(new_item, this);
			else
				this.list_node.content_node.appendChild(new_item);
				
			current_block = block_cache;
			
			tmpl.start_collapsed = save_collapse;
			
			return new_item;
		}
		return null;
	}
	add_node.setAttribute("onclick", "javascript:this.handle_click()");
	node.add_node = add_node;
	content_node.appendChild(add_node);
	
	push_block(node, BLOCK_list);
}

function list_item(item_values)
{
	if (current_block.block_type == BLOCK_list)
	{
		var tmpl = templates[current_block.template_name];
		if (tmpl)
		{
			var item = tmpl.construct(current_block, item_values, current_block.list_style, current_block.item_style);
			if (current_block.add_node.parentNode == current_block.content_node)
				current_block.content_node.insertBefore(item, current_block.add_node);
			else
				current_block.content_node.appendChild(item);
			
			return item;
		}
	}
	return null;
}

function endblock()
{
	var ret_block = current_block;
	if (current_block != null)
	{
		if (current_block.parent_block == null)
		{
			document.body.appendChild(current_block);
		}
		else
		{
			current_block.parent_block.appendChild(current_block);
		}
		current_block = current_block.parent_block;
	}
	return ret_block;
}

function line()
{
	var node_type = "DIV";
	if (current_block.block_type == BLOCK_table) node_type = "TR";
	var node = document.createElement(node_type);
	node.className = current_block.block_type + "_line " + current_block.id + "_line";
	node.block_name = current_block.id;
	
	push_block(node, BLOCK_line);
}

function endline()
{ return endblock(); }

function attribute(attr_name, attr_label, attr_type, attr_value, extra_class)
{
	var node_type = "DIV";
	if (current_block.nodeName == "TR") node_type = "TD";
	var node = document.createElement(node_type);
	node.className = "attribute" + (extra_class?" "+extra_class:"");
	node.id = attr_name;
	node.attribute_type = attr_type;
	
	var block_name = current_block.id;
	if (current_block.block_type == BLOCK_line || current_block.block_type == BLOCK_listitem) block_name = current_block.block_name;
	
	if (attr_label != null)
	{
		var lbl_node = document.createElement("SPAN");
		lbl_node.setAttribute("for", attr_name + "_value");
		lbl_node.className = block_name + "_line_label label" + (extra_class?" " + extra_class:"");
		lbl_node.id = attr_name + "_label";
		lbl_node.innerHTML = attr_label;
		
		node.appendChild(lbl_node);
	}
	
	var val_node = null;
	if (attr_type == TYPE_label)
	{
		var val_node = document.createElement("DIV");
		val_node.className = block_name + "_line_value value";
		val_node.id = attr_name + "_value";
		val_node.innerText = attr_value;
	}
	else if (attr_type == TYPE_token)
	{
		// special case for the token image
		var a_node = document.createElement("A");
		a_node.setAttribute("href", "gamerstoolkit://chooseToken");
		a_node.setAttribute("alt", "Click to Select Token");
		a_node.className = "token_link";
		node.appendChild(a_node);
		
		var img_node = document.createElement("IMG");
		img_node.setAttribute("src", "data:image/jpeg;base64," + attr_value);
		img_node.className = block_name + "_line_value token_image";
		img_node.id = attr_name + "_value";
		
		node.value_node = img_node;
		a_node.appendChild(img_node);
	}
	else if (attr_type == TYPE_option)
	{
		val_node = document.createElement("SELECT");
		val_node.className = block_name + "_line_value value_select";
		val_node.id = attr_name + "_value";
		
		var val = attr_value["attr_value"];
		var option;
		for (key in attr_value)
		{
			if (key != "attr_value")
			{
				option = document.createElement("OPTION");
				option.id = "option_" + attr_name + "_" + key;
				if (key == val)
					option.setAttribute("selected", "");
				option.setAttribute("value", key);
				option.innerText = attr_value[key];
				val_node.appendChild(option);
			}
		}
	}
	else if (attr_type == TYPE_slider)
	{
		val_node = document.createElement("INPUT");
		val_node.className = "value_edit";
		val_node.id = attr_name + "_value";
		val_node.setAttribute("type", "hidden");
		
		if (attr_value instanceof Array && attr_value[1] > 1)
		{
			val_node.value = attr_value[0];
			node.slider_max = attr_value[1];
			node.slider_ticks = new Array();
			
			node.onmouseup = function(e)
			{
				this.mouse_capture = false;
			}
			node.set_value = function(v)
			{
				this.value_node.value = v;
				
				for (var i = 0; i < this.slider_ticks.length; ++i)
				{
					if (i < v)
					{
						this.slider_ticks[i].setAttribute("tick_state", "on");
					}
					else
					{
						this.slider_ticks[i].setAttribute("tick_state", "off");
					}
				}
			}
			
			for (var i = 0; i < node.slider_max; ++i)
			{
				var tick = document.createElement("DIV");
				tick.className = "slider_tick";
				tick.id = attr_name + "_tick_" + i;
				tick.tick_index = i;
				tick.attr_node = node;
				
				tick.setAttribute("tick_state", (i < val_node.value)?"on":"off");
				
				tick.handle_click = function()
				{
					if (this.tick_index == this.attr_node.value_node.value - 1 &&
						this.getAttribute("tick_state") == "on")
					{
						this.attr_node.set_value(this.tick_index);
					}
					else
					{
						this.attr_node.set_value(this.tick_index + 1);
					}
				}
				tick.onclick = tick.handle_click;
				
				node.slider_ticks[i] = tick;
				node.appendChild(tick);
			}
		}
	}
	else if (attr_type == TYPE_text)
	{
		val_node = document.createElement("TEXTAREA");
		val_node.className = "text_area value_edit";
		val_node.id = attr_name + "_value";
		
		val_node.innerText = attr_value;
	}
	else
	{
		val_node = document.createElement("INPUT");
		if (attr_type == TYPE_bool)
		{
			val_node.setAttribute("type", "checkbox");
			if (attr_value == "true")
			{
				val_node.setAttribute("checked", "");
			}
		}
		else
		{
			val_node.setAttribute("type", "text");
			val_node.setAttribute("value", attr_value);
		}
		
		val_node.className = block_name + "_line_value value_edit";
		val_node.id = attr_name + "_value";
	}		
	
	if (val_node)
	{
		if (extra_class)
		{
			val_node.className = val_node.className + " " + extra_class;
		}
		
		val_node.attachments = new Array();
		val_node.handle_change = function ()
		{
			for (i = 0; i < this.attachments.length; ++i)
			{
				if (this.attachments[i] &&
					this.attachments[i].attachment_changed)
				{
					this.attachments[i].attachment_changed(
														   this.attachments[i], this);
				}
			}
		}
		val_node.setAttribute("onchange", "javascript:this.handle_change()");
		node.value_node = val_node;
		node.appendChild(val_node);
	}
	
	current_block.appendChild(node);
	
	return node;
}

function attach_attribute(attr_node, attach_node, callback)
{
	attr_node.attachment_changed = callback;
	attach_node.attachments.push(attr_node);
	callback(attr_node, attach_node);
}

var tmpl;
tmpl = new list_template("StringList");
tmpl.add_attribute("s", null, TYPE_string, "");
register_template(tmpl);

tmpl = new list_template("DieRollList");
tmpl.add_attribute("name", "Tag", TYPE_string, "");
tmpl.add_attribute("roll", "Notation", TYPE_string, "");
if (typeof(Dice) === 'undefined')
{
	tmpl.post_construct = function(item)
	{
		add_die_roll(item, "[.name]=[.roll]");
	}
}
else
{
	tmpl.post_construct = function(item)
	{
		add_die_roll(item, "[.roll]","[.name]=%t");
	}
}
register_template(tmpl);

function breadth_first_search(node, search_id)
{
	if (node.id == search_id) return node;
	
	var found = null;
	
	if (node.nextSibling)
		found = breadth_first_search(node.nextSibling, search_id);	
	
	if (found == null && node.firstChild)
		found = breadth_first_search(node.firstChild, search_id);
	
	return found;
}

// 1. attribute
// 2. attribute[n]
// 3. attribute.sub
// 4. attribute[n].sub

function ValueFromNode(node)
{	
	if (typeof(node) == "string") return node;
	
	if (node)
	{
		switch (node.nodeName)
		{
			case "DIV":
				return node.innerText;
				break;
			case "INPUT":
			{
				switch (node.type)
				{
					case "text":
					case "hidden":
						return node.value;
						break;
					case "checkbox":
						return node.checked?"true":"false";
						break;
				}
				break;
			}
			case "TEXTAREA":
				return node.value;
				break;
			case "SELECT":
				return node.options[node.selectedIndex].value;
				break;
		}
	}
	
	return "[[empty]]";
}

var GetAttributeValue = function (path)
{
	var node = GetAttributeNode(path);
	return ValueFromNode(node);
}

var GetAttributeNode = function (path)
{
	dbgOut.writeln("GetValue(" + path + ")");
	
	var attrs = path.split(".");
	
	if (attrs.length < 1 || attrs.length > 2)
		return null;
	
	var attr = attrs[0];
	dbgOut.writeln("  " + attr + ":");
	
	var aii = attr.indexOf("[");
	var ai = -1;
	if (aii >= 0)
	{
		ai = Math.floor(attr.substring(aii+1,attr.length-1));
		attr = attr.substring(0,aii); 
		dbgOut.writeln("   array " + attr + "[" + ai + "]");
	}
	
	var node = document.getElementById(attr)
	
	if (node)
	{
		if (ai >= 0 && node.block_type == BLOCK_list)
		{ // case 2 & 4
			var list_node = node;
			node = node.content_node.firstChild;
			var idx = -1;
			
			while (node)
			{
				if (node && node["block_type"] == BLOCK_listitem)
				{
					dbgOut.write(".");
					++idx;
					if (idx == ai)
					{
						break;
					}
				}
				node = node.nextSibling;
			}
			dbgOut.writeln(node?node.id:"<null>");
			
			if (node == null) return "[[outofbounds]]";
			
			if (attrs.length == 1)
			{
				var template = templates[list_node.template_name];
				if (template.attributes.length == 1)
				{
					node = breadth_first_search(node.firstChild, template.attributes[0].attribute_name + "_container");
					if (node)
						node = breadth_first_search(node.firstChild, template.attributes[0].attribute_name);
				}
			}
		}
		
		// we should now have attribute or attribute[n].
		
		if (attrs.length == 2)
		{ // case 3 & 4
			attr = attrs[1];
			if (ai >= 0)
			{
				node = node.attrs[attr].attribute_node;
			}
			else
			{
				node = breadth_first_search(node.firstChild, attr);
			}
		}
	}
	
	if (node == null && ai >= 0) return "[[outofbounds]]";		
	
	// now we have the fully qualified attribute
	if (node) node = node.value_node;
	
	return node;
}

function SetImageData(varname, data)
{
	var node = document.getElementById(varname);
	if (node && node.value_node && node.value_node.nodeName == "IMG")
	{
		node.value_node.setAttribute("src", "data:img/jpeg;base64," + data); 
	}
}

var current_selection = null;

function mark_script(s)
{
	var start = s.i;
	s.stack.push("}");
	++s.i;
	_resolve_dynamic_string(s);
	var end = s.i;
	++s.i;
	s.stack.pop();
	
	var substr = s.str.substring(start+1,end);
	var resolved = eval(substr);
	
	// re-resolve this section
	s.i = start-1;
	
	s.str = s.str.replace("{" + substr + "}", resolved);
}

function mark_attrib(s)
{
	var start = s.i;
	s.stack.push("]");
	++s.i;
	_resolve_dynamic_string(s);
	var end = s.i;
	++s.i;
	s.stack.pop();
	
	var substr = s.str.substring(start+1,end);
	var resolved = substr;

	if (resolved.charAt(0) == '.' && current_selection.block_type == BLOCK_listitem)
	{
		resolved = ValueFromNode(current_selection.attrs[resolved.substr(1)].attribute_node.value_node);
	}
	else
	{
		resolved = GetAttributeValue(resolved);
	}
	
	// re-resolve this section
	s.i = start-1;
	
	s.str = s.str.replace("[" + substr + "]", resolved);
}

function _resolve_dynamic_string(s)
{
	while (s.i < s.str.length)
	{
		if (s.str.charAt(s.i) == "[")
		{
			mark_attrib(s);
		}
		else if (s.str.charAt(s.i) == "{")
		{
			mark_script(s);
		}
		else if (s.str.charAt(s.i) == s.stack[s.stack.length-1])
		{
			return;
		}
		
		++s.i;
	}
}

function resolve_dynamic_string(str)
{
	var s = {str:str,i:0,stack:new Array()};
	
	_resolve_dynamic_string(s);
	
	return s.str;
}

function prep_die_roll()
{
	var str = resolve_dynamic_string(current_selection.dice_string);
	
	str = str.replace("+-","-"); // handle negative numbers without a lot of conditional inline 
	
	return str;
}

function __add_die_roll(node, dice_string)
{
	if (node && dice_string)
	{
		node.onclick = function(e)
		{
			if (current_selection && current_selection.hasAttribute("gtselected"))
			{
				current_selection.removeAttribute("gtselected");
			}

			this.setAttribute("gtselected","true");
			this.dice_string = dice_string;

			current_selection = this;
			
			e.stopPropagation();
			
			if (!debug)
			{
				window.location.replace("gamerstoolkit://prepDieRoll?notation=" + encodeURIComponent(prep_die_roll()));
			}
		}
	}
}

function add_die_roll(node, dice_string, display_string)
{
	if (typeof(Dice) === 'undefined')
	{
		__add_die_roll(node, dice_string);
		return;
	}
	
	if (node && dice_string)
	{
		node.dice_string = dice_string;
		node.display_string = display_string;
		
		if (node.display_string == null) node.display_string = [];
		
		node.onclick = function(e)
		{
			if (current_selection && current_selection.hasAttribute("gtselected"))
			{
				current_selection.removeAttribute("gtselected");
			}

			this.setAttribute("gtselected","true");

			current_selection = this;
			
//			if (!debug)
//			{
//				window.location.replace("gamerstoolkit://prepDieRoll?notation=" + prep_die_roll());
//			}
			
			e.stopPropagation();
			return false;
		}
	}
}

var HandleShake = function ()
{
	//window.alert("handle shake. " + current_selection + ", " + current_selection.dice_string);
	if (current_selection && current_selection.dice_string)
	{
		if (current_selection.display_string)
		{
			var formatting = new Array();
			
			if (typeof(current_selection.display_string) == 'string')
			{
				formatting[0] = resolve_dynamic_string(current_selection.display_string);
			}
			else 
			{
				for (var i = 0; i < current_selection.display_string.length; ++i)
				{
					formatting[i] = resolve_dynamic_string(current_selection.display_string[i]);
				}
			}
			rollDice(resolve_dynamic_string(current_selection.dice_string),formatting);
		}
		else
		{
			var str = prep_die_roll();
	//		window.alert("rolling: " + str);
	
			if (debug)
			{
				alert("rolling: " + str);
			}
			else
			{
				window.location.replace("gamerstoolkit://dieRoll?notation=" + 
				encodeURIComponent(str));
			}
		}
	}
}

var DisplayDieRollResults = function (results)
{
	alert(results);
}

function AddDieRollList(list)
{
	block_list("DieRolls", "DieRollList", "Frequent Die Rolls", LISTSTYLE_rows, ITEMSTYLE_columns);
	for (i = 0; i < list.length; ++i)
	{
		list_item(list[i]);
	}
	endblock();
}
