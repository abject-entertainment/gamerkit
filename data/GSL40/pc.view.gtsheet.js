
function generateHTML(data)
{
	data.strings = includeObject("./strings.json").en;
	return generateStaticHTML(_template, data, {
		helpers: {
			'ability_bonus': function abilityBonusHelper(value, options)
			{
				var bonus = Math.floor(value/2)-5;
				return (bonus>=0?"+":"") + bonus;
			},
			'value_of': function (obj, prop, options)
			{
				return obj[prop];
			},
			'concat': function ()
			{
				var args = Array.prototype.slice.call(arguments, 0, arguments.length-1)
				if (args.every(function (i) { return Array.isArray(i); }))
				{
					var first = args.shift();
					return first.concat.apply(first, args);
				}
				else if (args.length == 2 && Array.isArray(args[0]))
				{
					return args[0].map(function (i)
						{ return i + args[1]; });
				}
				else if (args.length == 2 && Array.isArray(args[1]))
				{
					return args[1].map(function (i)
						{ return args[0] + i; });
				}
				else
				{
					return args.join("");
				}
			},
			'join': function (list, delimiter, options)
			{
				return list.join(delimiter);
			},
			'filter_each': function (list, property, value, options)
			{
				var total = "";
				for (var i = 0; i < list.length; ++i)
				{
					if (list[i][property] == value)
					{
						total = total + options.fn(list[i]);
					}
				}
				return total;
			},
			'padded_each': function (list, min, min_extra, options)
			{
				var total = "";
				var i = 0;
				for (; i < list.length; ++i)
				{
					total = total + options.fn(list[i]);
				}
				for (var extra = 0; i < min || extra < min_extra; ++i, ++extra)
				{
					total = total + options.fn(" ");
				}

				return total;
			},
			'half_value': function (value, options)
			{
				return Math.floor(value / 2);
			},
			'quarter_value': function (value, options)
			{
				return Math.floor(value / 4);
			},
			'next_level': function (curXP, options)
			{
				var level = 1;
				var next = 0;
				while (curXP > 0)
				{
					next += 1000 * level;
					curXP -= 1000 * level;
					++level;
				}

				return next;
			}
		}
	});
}

var _template = 
"<html>\n" +
"\t<head>\n" +
"\t\t<title>{{character.Name}}</title>\n" +
"\t\t<meta name=\"apple-mobile-web-app-capable\" content=\"yes\">\n" + 
"\t\t<meta name = \"viewport\" content = \"width = device-width, initial-scale = 1.0, user-scalable = no\">\n" + 
"\t\t<meta name=\"format-detection\" content=\"telephone=no\">\n" + 
"\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"charsheet.css\" />\n" + 
"\t\t<link rel=\"stylesheet\" type=\"text/css\" href=\"dice.css\" />\n" + 
"\t\t<style>\n" + includeText("./pc.view.gtsheet.css") + "\n\t\t</style>\n" +
"\t\t<script type=\"text/javascript\" src=\"dice.js\"></script>\n" +
"\t\t<script type=\"text/javascript\" src=\"charsheet.js\"></script>\n" +
"\t</head>\n" +
"\t<body onload='javascript:createWidgets();'>\n" + includeText("./pc.view.gtsheet.hbs") + "\t</body>\n" +
"</html>";

module.exports.generateHTML = generateHTML;