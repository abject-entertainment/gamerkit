
var plist = require("plist");
var semver = require("semver");

var rootDir = __dirname + "/../data";
var fs = require("fs");

var dirFiles = fs.readdirSync(rootDir);
var packList = JSON.parse(fs.readFileSync("content/packs.json").toString('utf8'));

var appData = plist.parse(fs.readFileSync("../ios/gamerkit/Info.plist").toString('utf8'));
var appCurrentVersion = appData["CFBundleVersion"];

console.log("App Current Version:", appCurrentVersion);

for (var f = 0; f < dirFiles.length; ++f)
{
	try
	{
		var id = dirFiles[f];
		var path = rootDir + "/" + id;
		var stat = fs.statSync(path);
		if (stat && stat.isDirectory && fs.existsSync(path + ".pack"))
		{
			console.log("Found package: " + id);
			var packData = fs.readFileSync(path + "/package");
			packData = plist.parse(packData.toString('utf8'));
			packData = packData[0]; // array of package metadata: [id, desc, name, pack-type, version]

			if (packData[0] != id)
				{ console.warn(" ! ID mismatch: " + id + " v. " + packData[0]); }

			if (!(id in packList))
			{
				packList[id] = {
					versions: [
						{
							version: packData[4].toString(), 
							appVersion: ">=2.0.0" 
						}
					]
				};
			}

			packSettings = packList[id];

			packSettings.name = packData[2];
			packSettings.description = packData[1];

			// verify a versions entry with latest pack version and latest app version
			var vfound = false;
			var pversion = packData[4].toString();
			for (var v = 0; v < packSettings.versions.length; ++v)
			{
				var vset = packSettings.versions[v];
				if (vset.version == pversion && semver.satisfies(appCurrentVersion, vset.appVersion))
				{
					vfound = true;
					break;
				}
			}

			if (!vfound)
			{
				console.warn(" ! Update version settings for", id);
			}

			if (!fs.existsSync("content/files/" + pversion))
				{ fs.mkdirSync("content/files/" + pversion); }

			fs.writeFileSync("content/files/" + pversion + "/" + id + ".pack",
				fs.readFileSync(path + ".pack"));
		}
	}
	catch (err)
	{
		console.log("Error: " + err.toString());
	}
}

fs.writeFileSync("content/packs.json", new Buffer(JSON.stringify(packList, null, "\t")));
