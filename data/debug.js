
var debug = false;

if (debug)
{
	console.error("Loading debug functions...");
	_prefix = ""
	exports.log = function () {
		var args = Array.prototype.slice.call(arguments);
		args.unshift(_prefix);
		console.error.apply(console, args);
	}

	exports.log.indent = function () {
		_prefix += "  ";
	}

	exports.log.outdent = function () {
		_prefix = _prefix.substr(2);
	}
}
else
{
	exports.log = function () {};
	exports.log.indent = function () {};
	exports.log.outdent = function () {};
}