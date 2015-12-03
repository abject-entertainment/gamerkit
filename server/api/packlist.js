
var semver = require("semver");

var packData = require("../content/packs.json");
var contentRoot = null;

function log()
{
	//console.log.apply(console, arguments);
}

function handlePackList(req, res)
{
	if (!packData)
	{
		res.status(500).type('xml').send("<error>Package data not found</error>");
	}

	log(packData);

	var body = "<packages>\n";

	for (var packId in packData)
	{
		log("-- checking package " + packId);
		var pack = packData[packId];
		log(pack.versions);
		for (var v = 0; v < pack.versions.length; ++v)
		{
			log("-- checking version " + req.params.version + " vs. " + pack.versions[v].appVersion);

			if (semver.satisfies(req.params.version, pack.versions[v].appVersion))
			{
				var pbody = "";

				pbody += '\t<package id="' + packId + '" version="' + pack.versions[v].version + '"';
				if ("store" in pack)
					{ pbody += ' app-store-id="' + pack.store[req.params.platform] + '"'; }
				pbody += '>\n';

				pbody += '\t\t<name><![CDATA[' + pack.name + ']]></name>\n';

				pbody += '\t\t<description><![CDATA[' + pack.description + ']]></description>\n';

				pbody += '\t\t<notes><![CDATA[';
				pbody += (("description" in pack.versions[v])?pack.versions[v].description:"");
				pbody += ']]></notes>\n';

				pbody += '\t\t<package-url><![CDATA[';
				if ("url" in pack.versions[v])
					{ pbody += pack.versions[v].url; }
				else
				{
					var contentPath = contentRoot;
					if (contentPath.substr(0,4) !== "http")
					{
						contentPath = req.protocol + "://" + req.hostname + contentPath;
					}
					pbody += contentPath + "/" + pack.versions[v].version + "/" + packId + ".pack";
				}
				pbody += ']]></package-url>\n';

				pbody += '\t</package>\n';

				log("-- adding:\n" + pbody);
				body += pbody;
				break;
			}
			else
			{
				log("-- version does not match");
			}
		}
	}

	body += "</packages>";

	res.status(200).type('xml').send(body);
}

module.exports.register = function _register(app, root, content)
{
	contentRoot = content;
	app.get(root + "/packlist/:platform/:version/:deviceId", handlePackList);
}