var l = require("../../debug").log;

function Attribute(xmlNode, system)
{
	this.name = xmlNode.getAttribute('name');
	this.display_name = xmlNode.getAttribute('display-name');
	this.value_type = xmlNode.getAttribute('value-type');

	this.system = system;

	l("> Loading Attribute", this.display_name, "(" + this.name + ")", "of type", this.value_type);
	
	if (this.value_type.startsWith("list(") &&
		this.value_type.endsWith(")"))
	{
		this.isList = true;
		this.value_type = this.value_type.substr(5, this.value_type.length-6);
	}
 
	if (this.value_type === 'option' ||
		this.value_type === 'option...')
	{
		this.options = [];
		for (var o = 0; o < xmlNode.childNodes.length; ++o)
		{
			var opt = xmlNode.childNodes[o];
			if (opt.nodeName === 'option')
			{
				this.options.push({
					name: opt.getAttribute('name'),
					value: opt.getAttribute('value')
				});
			}
		}
	}
	else if (this.value_type in system.dataSets)
	{
		this.value_type = system.dataSets[this.value_type];
	}
}

module.exports = exports = Attribute;
