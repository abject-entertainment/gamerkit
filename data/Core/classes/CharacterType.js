
var CharacterSheet = require("./CharacterSheet");

function CharacterType(xmlNode, system)
{
	this.name = xmlNode.getAttribute('name');
	this.display_name = xmlNode.getAttribute('display-name');
	this.sort_as = xmlNode.getAttribute('sort-as');

	this.system = system;

	this.attributes = {};
	this.sheets = {
		edit: null,
		view: null,
		print: null,
		export: null
	};

	for (var c = 0; c < xmlNode.childNodes.length; ++c)
	{
		var child = xmlNode.childNodes[c];

		if (child.nodeName === 'attributes')
		{
			for (var a = 0; a < child.childNodes.length; ++a)
			{
				var attr = child.childNodes[a];
				if (attr.nodeName === 'attribute')
				{
					this.attributes[attr.getAttribute('name')] = system.attributes[attr.getAttribute('name')];
				}
			}
		}
		else if (child.nodeName === 'sheets')
		{
			for (var s = 0; s < child.childNodes.length; ++s)
			{
				var sheet = child.childNodes[s];
				if (sheet.nodeName in this.sheets)
				{
					if (this.sheets[sheet.nodeName])
					{
						console.error("!! Duplicate sheet definition found:", sheet.nodeName);
					}
					
					this.sheets[sheet.nodeName] = new CharacterSheet(sheet, system);
				}
			}
		}
	}
}

CharacterType.prototype.getSheet = function getSheet(action)
{ //console.log("getting", action, "(", this.sheets[action], ")");
	// fallthroughs are intentional for defaulting
	switch (action)
	{
		case 'export': 
			if (this.sheets.export)
				{ return this.sheets.export }
		case 'print': 
			if (this.sheets.print)
				{ return this.sheets.print }
		case 'view':
			if (this.sheets.view)
				{ return this.sheets.view }
		case 'edit':
		default:
			if (this.sheets.edit)
				{ return this.sheets.edit }
	}
}

module.exports = exports = CharacterType;