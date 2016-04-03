
var l = require("../../debug").log;

var Attribute = require("./Attribute");

function DataSet(xmlNode, system)
{
	this.name = xmlNode.getAttribute('name');
	this.attributes = {};

	this.system = system;

	l("! Loading DataSet", this.name);
	l.indent();

	for (var c = 0; c < xmlNode.childNodes.length; ++c)
	{
		var child = xmlNode.childNodes[c];
		if (child.nodeName === 'data')
		{
			child = new Attribute(child, system);
			if (child.name in this.attributes)
			{
				console.error("Duplicate property in dataset:", child.name);
			}

			this.attributes[child.name] = child;
		}
	}

	l.outdent();
}

module.exports = exports = DataSet;