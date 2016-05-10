
function generateHTML(data)
{
	data.strings = selectLanguage(includeObject("./strings.json"));

	data.fn_string = function () { return function stringHelper(text, render)
	{
		return data.strings[render(text)];
	}};

	data.fn_ability_bonus = function () { return function abilityBonusHelper(text, render)
	{
		if (render)
			{ text = render(text); }
		var bonus = Math.floor(text/2)-5;
		return (bonus>=0?"+":"") + bonus;
	}};

	data.fn_ability_scores = function () { return function abilityScoresHelper(text, render)
	{
		var markup = '<div class="block ability"><div class="ability-name" id="' + text + 
			'_label">' + data.strings[text] + '</div><div class="ability-score" id="' + text +
			'">' + data.character[text] + '</div><div class="ability-misc">' + data.strings.ability_misc + 
			'</div><div class="ability-bonus calculated" id="' + text + '_bonus" data-roll="1d20+*">' +
			data.fn_ability_bonus()(data.character[text]) + '</div><div class="ability-help">' +
			data.strings[text + "_help"] + '</div>';
		
		data.character.Skills.forEach(function (skill)
		{
			if (skill.attribute == text)
			{
				markup += '<div class="skill item" id="' + skill.name + '"><div class="skill-name">' +
					skill.name + '</div><div class="skill-trained"><span class="checkbox">' +
					(skill.trained?'&#x2611;':'&#x2610;') + 
					'</span> Trained</div><div class="skill-stats" data-roll="1d20+*">' +
					skill.bonus + '</div></div>';
			}
		});
		return markup + '</div>';
	}};

	data.fn_half = function () { return function halfValueHelper(text, render)
	{
		return Math.floor((render(text) || 0) / 2);
	}};
	
	data.fn_quarter = function () { return function quarterValueHelper(text, render)
	{
		return Math.floor((render(text) || 0) / 4);
	}};
	
	data.fn_list = function () { return function listHelper(text, render)
	{
		return this[text].join(", ");
	}};

	data.fn_next_level = function () { return function nextLevelHelper(text, render)
	{
		var cur = parseInt(render(text));
		if (isNaN(cur))
			{ return "1000"; }

		var level = 1;
		var xp = 0;

		while (cur >= 0)
		{
			xp += level * 1000;
			cur -= (level++) * 1000;
		}
		return xp.toString();
	}};

	var template = "\t\t<style>\n" + includeText("./pc.print.gtsheet.css") + 
		"\n\t\t</style>\n" + includeText("./pc.print.gtsheet.mustache");

	return generateStaticHTML(template, data, []);
}

module.exports.generateHTML = generateHTML;