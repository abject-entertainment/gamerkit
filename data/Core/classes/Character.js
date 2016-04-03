
var l = require("../../debug").log;

var System = require('./System');

function Character(xmlDoc)
{
	this.system = xmlDoc.getAttribute('system');
	this.type = xmlDoc.getAttribute('type');

	this.data = {};

	var characterType = System.getSystem(this.system).characterTypes[this.type];
	loadAttributes(xmlDoc.childNodes, this.data, characterType);

	//console.error(this.data);
}

function gatherText(node)
{
	var s = "";
	for (var i = 0; i < node.childNodes.length; ++i)
	{
		var c = node.childNodes[i];

		if (c.nodeName == "#text" ||
			c.nodeName == "#cdata-section")
		{
			s += c.nodeValue;
		}
		else if (c.childNodes.length > 0)
		{
			s += gatherText(c);
		}
	}
	return s;
}

function loadAttributes(attrList, container, spec)
{
	for (var a = 0; a < attrList.length; ++a)
	{
		var attribute = attrList[a];
		if (Array.isArray(container))
		{
			if (attribute.nodeName === 'item')
			{ // list item

				if (typeof(spec) === 'string')
				{
					var val = gatherText(attribute).replace("\\n", "\n");
					switch (spec)
					{
						case 'bool':
							val = (val === 'true');
							break;
					}
					container.push(val);
				}
				else
				{
					var set = {};
					container.push(set);
					loadAttributes(attribute.childNodes, set, spec);
				}
			}
		}
		else if (attribute.nodeName in spec.attributes)
		{
			var type = spec.attributes[attribute.nodeName];

			if (type.isList)
			{
				container[attribute.nodeName] = [];
				loadAttributes(attribute.childNodes, container[attribute.nodeName], type.value_type);
			}
			else if (typeof(type.value_type) === 'string')
			{
				var val = gatherText(attribute).replace("\\n", "\n");
				switch (type.value_type)
				{
					case 'bool':
						val = (val === 'true');
						break;
				}
				container[attribute.nodeName] = val;
			}
			else
			{
				container[attribute.nodeName] = {};
				loadAttributes(attribute.children, container[attribute.nodeName], type.value_type);
			}
		}
		else if (attribute.nodeName === 'Token')
		{
			container.Token = gatherText(attribute);
		}
	}
}

Character.prototype.generateHTML = function generateHTML(action)
{
	var system = System.getSystem(this.system);
	var type = system.characterTypes[this.type];

	var sheet = type.getSheet(action);

	return sheet.generateHTML({ character: this.data });
}

Character.prototype.getPreviewData = function getPreviewData()
{
	return {
		system: this.system,
		name: this.data.Name,
		token: this.data.Token
	};
}

module.exports = exports = Character;
