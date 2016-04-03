
var fs = require('fs');
var path = require('path');

var plist = require('plist');
var LintStream = require('jslint').LintStream;
var browserify = require('browserify');
var uglifyjs = require('uglify-js');
var uglifycss = require('uglifycss');
var JSZip = require('jszip');

var fopts = { encoding: 'utf8', flag: 'w+' };
var l = console.log.bind(console, "[BUILD]");

function _js_writeFile(contents, fout, then)
{
	fs.writeFile(fout, contents, fopts, function _js_writeFile(err)
	{
		if (err) throw err;

		//l("  -->", fout);
		then();
	});
}

function _js_uglify(pretty, fout, then)
{
	var ugly = pretty;
	if (exports.uglify) // TURN UGLIFY ON OR OFF
	{
		l("(JS) uglify...");
		try
		{
			ugly = uglifyjs.minify(pretty, { fromString: true }).code;
		}
		catch (err)
		{
			l("uglifyjs error:");
			console.error(err);
		}
	}

	_js_writeFile(ugly, fout, then);
}

function _js_browserify(fin, fout, then)
{
	if (exports.browserify.indexOf(fin) >= 0)
	{
		l("(JS) browserify...");
		var b = browserify({
			entries: fin
		});
		var bundle = b.bundle();
		var bundled = "";
		bundle.on('readable', function _js_bundleDone()
		{
			var chunk = bundle.read();
			if (chunk && chunk.length > 0)
			{
				bundled += chunk.toString('utf8');
			}
			else
			{
				//l("  >>", bundled.substr(0, 25), "...");
				_js_uglify(bundled, fout, then);
			}
		});
	}
	else
	{
		fs.readFile(fin, function _js_bundleSkip(err, data)
		{
			if (err) throw err;

			_js_uglify(data.toString('utf8'), fout, then);
		})
	}
}

module.exports = exports = {

	loadPackageFile: function loadPackageFile(p, done)
	{
		p = path.join(p, "package");

		fs.readFile(p, 'utf8', function _loadPackageFile_readFile(err, data)
		{
			if (err) throw err;

			data = plist.parse(data);

			done(data);
		});
	},

	clearBuildDir: function clearBuildDir(p, then)
	{
		p = path.join(p, ".build");

		// if it doesn't exist, create it.
		fs.stat(p, function _clearBuildDir_stat(err, stat)
		{
			if (err)
			{
				if (err.code == 'ENOENT')
				{
					fs.mkdirSync(p);
					then();
				}
				else throw err;
			}

			if (stat.isDirectory())
			{
				function _recursiveRemove(p, then)
				{
					fs.readdir(p, function _clearBuildDir_readdir(err, files)
					{
						function _recursiveRemove_nextFile()
						{
							if (files.length > 0)
							{
								var f = files.shift();
								f = path.join(p, f);
								fs.stat(f, function _recurseStat(err, stat)
								{
									if (err) throw err;

									if (stat.isDirectory())
									{
										_recursiveRemove(f, function ()
										{
											fs.rmdir(f, _recursiveRemove_nextFile);
										});
									}
									else
									{
										fs.unlink(f, function _recurseUnlink(err)
										{
											if (err) throw err;

											_recursiveRemove_nextFile()
										});
									}
								});
							}
							else
							{
								then();
							}
						};

						_recursiveRemove_nextFile();
					});
				}

				_recursiveRemove(p, then);
			}
			else
			{
				throw p + " is not a directory.";
			}
		});
	},

	createPack: function createPack(dir, then)
	{
		l("(ZIP)");
		var zip = new JSZip();

		function addFiles(dir, inner, then)
		{
			fs.readdir(dir, function _zipFiles(err, files)
			{
				if (err) throw err;

				function addNextFile()
				{
					if (files.length > 0)
					{
						var file = files.shift();
						var src = path.join(dir, file);
						var dst = path.join(inner, file);

						fs.stat(src, function _zipStat(err, stat)
						{
							if (err) throw err;

							if (stat.isDirectory())
							{
								addFiles(src, dst, addNextFile);
							}
							else
							{
								fs.readFile(src, function _zipRead(err, data)
								{
									if (err) throw err;

									//l("  <--", file);
									zip.file(dst, data.toString('utf8'), { createFolders: true });
									addNextFile();
								});
							}
						});
					}
					else
					{
						then();
					}
				}

				addNextFile();
			});
		}

		addFiles(path.join(dir, '.build'), "", function _zipReady()
		{
			fs.writeFile('./' + dir + '.pack', zip.generate({ type: 'nodebuffer' }), { flags: 'w+' }, 
				function _zipDone(err)
				{
					if (err) throw err;

					//l(".");
					then();
				});
		});
	},

	fileHandlers: {
		js: function handle_js(fin, fout, then)
		{
			_js_browserify(fin, fout, then);
		},
		css: function handle_css(fin, fout, then)
		{
			// uglify
			fs.writeFile(fout, uglifycss.processFiles([fin]), fopts, function _css_writeFile(err)
			{
				if (err) throw err;

				then();
			});

		},
		gtsheet: function handle_sheet(fin, fout, then)
		{
			var loc = path.dirname(fin);

			// composite first, then treat as js
			fs.readFile(fin + ".js", function _sheet_readJS(err, data)
			{
				if (err) throw err;

				data = data.toString('utf8');

				var regex = /includeObject\("([^"]+)"\)/g;

				var match = null;
				while (match = regex.exec(data))
				{
					var inc = match[1];
					inc = fs.readFileSync(path.join(loc, inc), 'utf8');
					data = data.substr(0, match.index) + "(" + inc + ")" + data.substr(match.index + match[0].length);
				}

				regex = /includeText\("([^"]+)"\)/g;

				while (match = regex.exec(data))
				{
					var inc = match[1];
					inc = fs.readFileSync(path.join(loc, inc), 'utf8');
					inc = inc.replace(/\\/g, "\\\\").replace(/"/g, "\\\"").replace(/\n/g, "\\n");
					data = data.substr(0, match.index) + "\"" + inc + "\"" + data.substr(match.index + match[0].length);
				}

				//_js_writeFile(data, fout, then);
				_js_uglify(data, fout, then);
			});
		},
		_: function handle_other(fin, fout, then)
		{
			fs.readFile(fin, function _other_readFile(err, data)
			{
				if (err) throw err;

				fs.writeFile(fout, data, fopts, function _other_writeFile(err)
				{
					if (err) throw err;

					then();
				});
			});
		},
		_dir: function handle_directory(fin, fout, then)
		{
			fs.mkdir(fout, function _dir_mkdir(err)
			{
				if (err) throw err;

				fs.readdir(fin, function _dir_readdir(err, files)
				{
					if (err) throw err;

					function _dir_nextFile()
					{
						if (files.length > 0)
						{
							var f = files.shift();
							var src = path.join(fin, f);
							var dst = path.join(fout, f);

							fs.stat(src, function _dir_stat(err, stat)
							{
								if (err) throw err;

								if (stat.isDirectory())
								{
									exports._dir(src, dst, _dir_nextFile);
								}
								else
								{
									var out = fs.createWriteStream(dst, { flag: 'w+' });
									out.on('finish', function _dir_writefinish()
									{
										_dir_nextFile();
									});
									fs.createReadStream(src).pipe(out);
								}
							});
						}
						else
						{
							then();
						}
					}

					_dir_nextFile();
				});
			});
		}
	},

	l: l,
	browserify: [],
	uglify: true
}

exports.l.hr = "=====================";
