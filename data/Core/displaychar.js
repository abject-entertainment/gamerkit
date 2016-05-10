
var Character = require("./classes/Character");
var System = require("./classes/System");

var xml = require("xmldom");
//var handlebars = require('handlebars');
var mustache = require('mustache');

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

global.generateStaticHTML = function generateStaticHTML(template, data, libs)
{
	libs = libs || [];

	var t = template;
	var template = "<html>\n" +
		"\t<head>\n" +
		"\t\t<title>{{character.Name}}</title>\n" +
		"\t\t<meta name=\"apple-mobile-web-app-capable\" content=\"yes\">\n" + 
		"\t\t<meta name = \"viewport\" content = \"width = device-width, initial-scale = 1.0, user-scalable = no\">\n" + 
		"\t\t<meta name=\"format-detection\" content=\"telephone=no\">\n";

	var script = "";
	libs.forEach(function eachLib(lib)
	{
		switch (lib)
		{
			case "dynamic":
				template = template + 
					"\t\t<script type=\"text/javascript\">\n" +
					"\t\t\tvar character_data = " + JSON.stringify(data.character) + ";\n\t\t</script>\n" +
					"\t\t<script type=\"text/javascript\" src=\"" + lib + ".js\"></script>\n";
				break;
			default:
				// dice, widgets
				template = template + 
					"\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"" + lib + ".css\" />\n" + 
					"\t\t<script type=\"text/javascript\" src=\"" + lib + ".js\"></script>\n";
		}
		script = script + "\tinit_" + lib + "();\n";
	});

	template = template +
		"\t\t<script>\nfunction onLoad() {\n" + 
		"\t	if ('characterSheetReady' in window) { characterSheetReady(); }\n" + script + "\n}\n</script>\n" +
		"\t</head>\n" +
		"\t<body onload='javascript:onLoad();'>\n" + t + "\n";
	if (libs.indexOf("widgets"))
	{
		template = template +
			"\t\t<div id=\"charsheet-popup\" class=\"popup-screen\"><div id=\"popup-inner\" class=\"popup\"><div class=\"popup-done\">{{strings.done}}</div></div></div>\n";
	}
	template = template + "\t</body>\n</html>";

	return mustache.render(template, data);
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

function selectLanguage(strings)
{
	var langs = getPreferredLanguages();

	for (var i = 0; i < langs.length; ++i)
	{
		var l = langs[i];
		if (l in strings)
			{ return strings[l]; }
		else if (l.length > 2)
		{
			l = l.substr(0,2);
			if (l in strings)
				{ return strings[l]; }
		}
	}

	return strings.en;
}

global.generateCharacterHTML = generateCharacterHTML;
global.getCharacterPreviewData = getCharacterPreviewData;
