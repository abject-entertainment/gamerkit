
var Character = require("./classes/Character");
var System = require("./classes/System");

var xml = require("xmldom");
var handlebars = require('handlebars');

var parser = new xml.DOMParser();

global.loadSystem = function loadSystem(systemName)
{
	return new System(parser.parseFromString(loadSystemXML(systemName)).documentElement);
}

global.loadSheet = function loadSheet(systemName, fileName)
{
	var str = loadSheetModule(systemName, fileName);
	function __inside()
	{
		var module = { exports: {} };
		eval(str);
		return module.exports;
	}
	return __inside();
}

global.generateStaticHTML = function generateStaticHTML(template, data, options)
{
	if (typeof(template) !== 'function')
	{
		template = handlebars.compile(template);
	}

	return template(data, options);
}

function generateCharacterHTML(action, fileContents)
{
	if (['export', 'print', 'view', 'edit'].indexOf(action) >= 0)
	{
		var character = new Character(parser.parseFromString(fileContents).documentElement);
		return character.generateHTML(action);
	}
	return null;
}

function getCharacterPreviewData(fileContents)
{
	var character = new Character(parser.parseFromString(fileContents).documentElement);
	return character.getPreviewData();
}

function displayCharacter(action, fileContents, saveCallback)
{

}

global.generateCharacterHTML = generateCharacterHTML;
global.getCharacterPreviewData = getCharacterPreviewData;
//exports.displayCharacter = displayCharacter;