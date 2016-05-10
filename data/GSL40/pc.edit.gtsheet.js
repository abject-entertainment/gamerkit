
function generateHTML(data)
{
	data.strings = selectLanguage(includeObject("./strings.json"));
	data.attributes = [ "Str", "Con", "Dex", "Int", "Wis", "Cha" ];

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
			'" data-widget="field" data-bind="divtext: ' + text + '">' + data.character[text] + 
			'</div><div class="ability-misc">' + data.strings.ability_misc + 
			'</div><div class="ability-bonus calculated" id="' + text + 
			'_bonus" data-bind="text: Math.floor(' + text + '())-5">' +
			data.fn_ability_bonus()(data.character[text]) + '</div><div class="ability-help">' +
			data.strings[text + "_help"] + '</div>';
		
		data.character.Skills.forEach(function (skill)
		{
			if (skill.attribute == text)
			{
				markup += '<div class="skill item" id="' + skill.name + '"><div class="skill-name">' +
					skill.name + '</div><div class="skill-trained"><span class="checkbox">' +
					(skill.trained?'&#x2611;':'&#x2610;') + 
					'</span> Trained</div><div class="skill-stats">' +
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

	var template = "\t\t<style>\n" + includeText("./pc.edit.gtsheet.css") + 
		"\n\t\t</style>\n" + includeText("./pc.edit.gtsheet.mustache");

	return generateStaticHTML(template, data, ["widgets", "dynamic"]);
}

module.exports.generateHTML = generateHTML;