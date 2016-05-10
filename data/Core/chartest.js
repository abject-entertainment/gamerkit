
var fs = require('fs');
var path = require('path');

// expected to exist when character is displayed
global.loadSystemXML = function loadSystemXML(systemName)
{
	return fs.readFileSync(path.join(__dirname, "..", systemName, systemName + '.gtsystem'), 'utf8');
}

global.loadSheetModule = function loadSheetScript(systemName, sheetFile)
{
	return fs.readFileSync(path.join(__dirname, "..", systemName, sheetFile + '.js'), 'utf8');
}

global.getPreferredLanguages = function getPreferredLanguages()
{
	return ["en"];
}

// needed to display character in test case (not needed after package build)
var curRoot = "";
global.includeObject = function includeObject(file)
{
	file = "../" + path.join(curRoot, file);
	console.error("Including:", file);
	var result = require(file);
	//console.error(result);
	return result;
}

global.includeText = function includeText(file)
{
	file = "./data/" + path.join(curRoot, file);
	console.error("Including:", file);
	var result = fs.readFileSync(file, 'utf8');
	//console.error(result);
	return result;
}

var action = process.argv[2];
var character = process.argv[3];

curRoot = path.dirname(character);
character = fs.readFileSync(path.join("data", character), 'utf8');

require('./displaychar');

if (action == "preview")
	console.log(getCharacterPreviewData(character));
else
	console.log(generateCharacterHTML(action, character));
