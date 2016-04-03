
var l = require('../../debug').log;

var DataSet = require('./DataSet');
var Attribute = require('./Attribute');
var CharacterType = require('./CharacterType');

g_systems = {};

function System(xmlDoc)
{
	this.name = xmlDoc.getAttribute('name');
	this.display_name = xmlDoc.getAttribute('display-name');

	l("! Loading System:", this.display_name, "(" + this.name + ")");

	this.dataSets = {};
	this.attributes = {};
	this.characterTypes = {};

	var sections = {
		'datasets': { node: 'dataset', constructor: DataSet, collection: this.dataSets }, 
		'attributes': { node:'attribute', constructor: Attribute, collection: this.attributes },
		'character-types': { node: 'character-type', constructor: CharacterType, collection: this.characterTypes }
	};

	for (var c = 0; c < xmlDoc.childNodes.length; ++c)
	{
		var child = xmlDoc.childNodes[c];

		if (child.nodeName in sections)
		{
			l(" > Loading:", child.nodeName);
			l.indent();

			var section = sections[child.nodeName];
			for (var cc = 0; cc < child.childNodes.length; ++cc)
			{
				var element = child.childNodes[cc];
				if (element.nodeName === section.node)
				{
					element = new (section.constructor)(element, this);

					if (element.name in section.collection)
					{
						console.error("!! Duplicate object with name", element.name, "already exists in", child.nodeName);
					}

					section.collection[element.name] = element;
				}
			}

			l.outdent();
			delete sections[child.nodeName];
		}
	}

	g_systems[this.name] = this;
}

System.getSystem = function getSystem(name)
{
	if (g_systems[name] == null)
	{
		g_systems[name] = global.loadSystem(name);
	}
	return g_systems[name];
}

System.prototype.getFilePath = function getFilePath()
{
	return __gamerkit.getPathForSystemFiles(this.name);
}
module.exports = exports = System;