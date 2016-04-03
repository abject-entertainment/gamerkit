
function CharacterSheet(xmlNode, system)
{
	this.name = xmlNode.nodeName;
	this.display_name = xmlNode.getAttribute('name');
	this.file = xmlNode.getAttribute('file');
	this.system = system.name;
}

CharacterSheet.prototype.generateHTML = function generateHTML(charData)
{
	var sheetContent = loadSheet(this.system, this.file);

	if ('generateHTML' in sheetContent &&
		typeof(sheetContent.generateHTML) === 'function')
	{
		return sheetContent.generateHTML(charData);
	}
}


module.exports = exports = CharacterSheet;