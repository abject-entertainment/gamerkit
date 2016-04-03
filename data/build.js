
var fs = require('fs');
var path = require('path');

var b = require('./build-helpers');

var l = b.l;

b.uglify = false;

// needs browserify
b.browserify = [
	"Core/displaychar.js"
];

// Build packages
var packs = [
	"Core",
	"GSL40"
];

function nextPack()
{
	if (packs.length > 0)
	{
		var packName = packs.shift();
		l(packName, l.hr);
		var inRoot = path.join('.', packName);
		var outRoot = path.join('.', packName, '.build');

		var plist = b.loadPackageFile(inRoot, function _loadPlistDone(plist)
		{
			var packageMetadata = plist.shift();

			function nextFile()
			{
				if (plist.length > 0)
				{
					var file = plist.shift();
					file = file.substr(file.indexOf('/')+1); // remove device target directory

					l("--", file);

					var ext = file.lastIndexOf('.');
					ext = (ext>=0)?file.substr(ext+1):null;

					if (ext && ext in b.fileHandlers)
					{
						b.fileHandlers[ext](path.join(inRoot, file), path.join(outRoot, file), nextFile);
					}
					else if (file.endsWith("/*"))
					{
						file = file.substr(0, file.length-2);
						b.fileHandlers._dir(path.join(inRoot, file), path.join(outRoot, file), nextFile);
					}
					else
					{
						b.fileHandlers._(path.join(inRoot, file), path.join(outRoot, file), nextFile);
					}
				}
				else
				{
					var output = fs.createWriteStream(path.join(outRoot, 'package'), { flag: 'w+' });
					output.on('finish', function _copy_package(err)
					{
						if (err) throw err;

						b.createPack(packName, nextPack);
					});
					fs.createReadStream(path.join(inRoot, 'package')).pipe(output);
				}
			}

			b.clearBuildDir(inRoot, nextFile);
		});
	}
};

nextPack();


