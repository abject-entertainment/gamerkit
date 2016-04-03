// dice.js
// An HTML5-based dice roller

/*

DICE NOTATION ->

= Ignores all whitespace
= Multiple rolls can be separated by ','.

ROLL can be:
<N>d<S> = roll N dice with S sides each.
<N>da<S> = roll N dice with S sides each.  Each roll of S adds one more die to the roll (aces).
<N>du = roll N Ubiquity dice (0 or 1)
<N>df = roll N Fudge dice (1, 0, -1)
<N>dc = deal N cards from the deck

<ROLL>k<N> = keep the top N rolls
<ROLL>k<N>l = keep the lowest N rolls
<ROLL>d(<N>) = drop the lowest N rolls (defaults to 1)
<ROLL>r(<V>) = reroll all dice that rolled a value of V or less (defaults to 1)

<ROLL>(+|-)<V> = Add (or subtract) V from the value of the roll. V can be negative (<ROLL>+-3 is valid)
<ROLL>(+|-)<ROLL> = Add (or subtract) the values of two rolls.
These can chain.

/(\+\s*|-\s*)?(([0-9]*)d([0-9]+|u|f|c)(k[0-9]+|k[0-9]+l|d[0-9]+|r[0-9]+)?|[0-9]+)/gi

*/

var die_roller_debug = (typeof(debug)==='undefined')?false:debug;
var d;
if (die_roller_debug)
{ d = function(str) { console.log(str); }; }
else
{ d = function(str) {}; }


function DiceRoller()
{
	this.deck = null;
}

DiceRoller.standard_cards = [
	"HA", "H2", "H3", "H4", "H5", "H6", "H7", "H8", "H9", "H10", "HJ", "HQ", "HK",
	"DA", "D2", "D3", "D4", "D5", "D6", "D7", "D8", "D9", "D10", "DJ", "DQ", "DK",
	"SA", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9", "S10", "SJ", "SQ", "SK",
	"CA", "C2", "C3", "C4", "C5", "C6", "C7", "C8", "C9", "C10", "CJ", "CQ", "CK",
	"RJ!", "BJ!"
];

DiceRoller.prototype.shuffleDeck = function(deck_list)
{
	this.full_deck = deck_list;
	deck_list = deck_list.slice(0); // copy the array
	
	this.deck = new Array();
	
	while (deck_list.length > 0)
	{
		var idx = Math.floor(Math.random() * deck_list.length);
		this.deck.push(deck_list[idx]);
		deck_list.splice(idx,1);
	}
	
	d("Shuffled Deck: " + this.deck.join(", "));
}

DiceRoller.prototype.parse = function (notation) // returns parsed tree
{
	// get rid of whitespace
	notation = notation.replace(/\s/g,"").toLowerCase();

	d("Parsing dice roll notation: " + notation);
	
	// split into individual rolls
	var roll_list = notation.split(",");

	if (roll_list.length == 0) return null;
	
	d("..Iterating through " + roll_list.length + " rolls..");
	var result = new Object();
	result.type = 'list';
	result.rolls = new Array();
	
	for (var i = 0; i < roll_list.length; ++i)
	{
		var roll = roll_list[i];
		var parsed = this.parseRoll(roll);
		if (parsed)
			result.rolls.push({roll:parsed,notation:roll});
	}
	
	if (result.rolls.length > 0)
		return result;
	else
		return null;
}

DiceRoller.prototype.parseNumber = function(s)
{
	if (s.i >= s.notation.length) return Number.NaN;
	
	var numstr = "";
	// parse a number (with optional '-' at the beginning)
	if (s.notation.charAt(s.i) == '-')
	{
		numstr = "-";
		++s.i;
	}
	else
	{
		numstr = "";
	}
	
	var c = s.notation.charCodeAt(s.i++);
	while (c >= 0x30 && c <= 0x39)
	{
		numstr += String.fromCharCode(c);
		c = s.notation.charCodeAt(s.i++);
	}
	
	--s.i;
	if (numstr == "") return Number.NaN;
	
	return Number(numstr);
}

DiceRoller.prototype.parseRoll = function(notation) // returns parsed tree
{
	d(".. ..Parsing roll: " + notation);
	var idx = notation.search(/[+-]/);
	
	if (idx > 0) // a '-' at 0 is valid for a number literal
	{
		d(".. .. ..Add/Subtract");
		var result = new Object();
		result.type = ((notation.charAt(idx) == '+')?'add':'subtract');
		result.left = this.parseRoll(notation.substr(0,idx));
		result.right = this.parseRoll(notation.substr(idx+1));
		
		if (result.left && result.right)
			return result;
		else
			return null;
	}
	else
	{
		var s = {i:0, notation:notation};
		
		var num = this.parseNumber(s);
		
		// maybe done
		if (s.i >= s.notation.length)
		{
			d(".. .. ..Number Literal: " + num);
			var result = {type:'number',value:num};
			if (isNaN(result.value))
				return null;
			else
				return result;
		}
		
		// parse a 'd'
		if (num > 0 && s.notation.charAt(s.i++) == 'd')
		{
			result = {
				type:'roll',
				count:num,
				size:0,
				ace:false,
				drop_lowest:0,
				reroll_on:-99
			};
			
			// optionally parse an 'a'
			if (s.notation.charAt(s.i) == 'a')
			{
				++s.i;
				result.ace = true;
			}
			
			// parse a number or 'u', 'f', '%', 'c'
			c = s.notation.charAt(s.i++);
			if (c == 'u')
			{
				result.size = 1; // special case for Ubiquity (succes/fail)
			}
			else if (c == 'f')
			{
				result.size = -1; // special case for Fate (-1,0,+1)
			}
			else if (c == '%')
			{
				result.size = 100;
			}
			else if (c == 'c')
			{
				result.ace = false; // can't ace a deck of cards
				result.size = -52; // special case for a deck of cards
			}
			else
			{
				--s.i;
				result.size = this.parseNumber(s);
			}
			
			// maybe done
			if (s.i >= s.notation.length)
			{
				if (isNaN(result.size))
					return null;
				else
					return result;
			}
			
			// k, d or r
			c = s.notation.charAt(s.i++);
			num = this.parseNumber(s);
			if (c == 'k')
			{
				if (num > 0 && num < result.count)
				{
					result.drop_lowest = result.count - num;
				}
				else
				{
					return null;
				}
			}
			else if (c == 'd')
			{
				if (num > 0 && num < result.count)
				{
					result.drop_lowest = num;
				}
				else if (isNaN(num))
				{
					result.drop_lowest = 1;
				}
				else
				{
					return null;
				}
			}
			else if (c == 'r')
			{
				if (num > 0 && num < result.size)
				{
					result.reroll_on = num;
				}
				else if (isNaN(num))
				{
					result.reroll_on = 1;
				}
				else
				{
					return null;
				}
			}
		}
		else
		{
			return null;
		}
		
		d("Roll: " + JSON.stringify(result));
		return result;
	}
}

DiceRoller.prototype.rollTree = function(tree) // returns results tree
{
	var result = null;
	if (tree.type == 'list')
	{
		result = new Array();
		for (var i = 0; i < tree.rolls.length; ++i)
		{
			var roll = this.rollTree(tree.rolls[i].roll)[0];
			if (roll)
				result.push({roll: roll, notation: tree.rolls[i].notation});
		}
		return result;
	}
	else if (tree.type == 'add')
	{
		var left = this.rollTree(tree.left)[0];
		var right = this.rollTree(tree.right)[0];
		result = {rolls:[left,right], value:left.value+right.value, tree:tree};
	}
	else if (tree.type == 'subtract')
	{
		var left = this.rollTree(tree.left)[0];
		var right = this.rollTree(tree.right)[0];
		result = {rolls:[left,right], value:left.value-right.value, tree:tree};
	}
	else if (tree.type == 'roll')
	{
		result = {rolls:new Array(), value:0, tree:tree};
		
		var total_rolls = tree.count;
		for (var i = 0; i < total_rolls; ++i)
		{
			switch (tree.size)
			{
				case -52:
					{
						if (this.deck)
						{
							if (this.deck.length == 0)
							{
								this.shuffleDeck(this.full_deck);
							}
							result.rolls.push({value:this.deck.pop(),used:true,ace:false});
						}
						continue;
					}
					break;
				case -1:
					{
						var fate_result = Math.floor(Math.random()*3)-1;
						result.rolls.push({value:fate_result,used:true,ace:false});
						
						if (tree.ace && fate_result == 1)
						{
							result.rolls[result.rolls.length-1].ace = true;
							++total_rolls;
						}
					}
					break;
				case 1:
					{
						var ubiquity_result = Math.floor(Math.random()*2);
						result.rolls.push({value:ubiquity_result,used:true,ace:false});
						
						if (tree.ace && ubiquity_result == 1)
						{
							result.rolls[result.rolls.length-1].ace = true;
							++total_rolls;
						}
					}
					break;
				default:
					{
						var die_result = Math.floor(Math.random()*tree.size) + 1;
						result.rolls.push({value:die_result,used:true,ace:false});
						
						if (tree.ace && die_result == tree.size)
						{
							result.rolls[result.rolls.length-1].ace = true;
							++total_rolls;
						}
					}
			}
			if (result.rolls[result.rolls.length-1].value <= tree.reroll_on)
			{
				result.rolls[result.rolls.length-1].used = false;
				++total_rolls;
			}
		}
		
		if (tree.size != -52)
		{
			for (var i = 0; i < tree.drop_lowest; ++i)
			{
				var lowest_idx = -1;
				
				for (var j = 0; j < result.rolls.length; ++j)
				{
					if (lowest_idx < 0 && result.rolls[j].used == true)
					{
						lowest_idx = j;
					}
					else if (result.rolls[j].used && result.rolls[j].value < result.rolls[lowest_idx].value)
					{
						lowest_idx = j;
					}
				}
				
				result.rolls[lowest_idx].used = false;
			}
			
			var total = 0;
			for (var i = 0; i < result.rolls.length; ++i)
			{
				if (result.rolls[i].used)
				total += result.rolls[i].value;
			}
			result.value = total;
		}
	}
	else if (tree.type == 'number')
	{
		result = {rolls:null, value:tree.value, tree:tree};
	}
	return [result];
}

DiceRoller.prototype.displayRoll = function(result, node)
{
	if (result.tree.type == 'add')
	{
//		var sub = document.createElement("DIV");
//		sub.className = "die_sub_result";
		this.displayRoll(result.rolls[0], node, null);
		node.removeChild(node.lastChild);
//		node.appendChild(sub);
		
		sub = document.createElement("DIV");
		sub.className = "die_op";
		sub.innerHTML = " + ";
		node.appendChild(sub);
		
//		sub = document.createElement("DIV");
//		sub.className = "die_sub_result";
		this.displayRoll(result.rolls[1], node, null);
		node.removeChild(node.lastChild);
//		node.appendChild(sub);

		sub = document.createElement("DIV");
		sub.innerHTML = result.value;
		sub.className = "die_total";
		node.appendChild(sub);
	}
	else if (result.tree.type == 'subtract')
	{
//		var sub = document.createElement("DIV");
//		sub.className = "die_sub_result";
		this.displayRoll(result.rolls[0], node, null);
		node.removeChild(node.lastChild);
//		node.appendChild(sub);
		
		sub = document.createElement("DIV");
		sub.className = "die_op";
		sub.innerHTML = " - ";
		node.appendChild(sub);
		
//		sub = document.createElement("DIV");
//		sub.className = "die_sub_result";
		this.displayRoll(result.rolls[1], node, null);
		node.removeChild(node.lastChild);
//		node.appendChild(sub);

		sub = document.createElement("DIV");
		sub.innerHTML = result.value;
		sub.className = "die_total";
		node.appendChild(sub);
	}
	else if (result.tree.type == 'number')
	{
		var sub = document.createElement("DIV");
		sub.className = "die_constant";
		sub.innerHTML = result.value.toString();
		node.appendChild(sub);
		
		sub = document.createElement("DIV");
		sub.innerHTML = result.value;
		sub.className = "die_total";
		node.appendChild(sub);
	}
	else if (result.tree.type == 'roll')
	{
		for (var i = 0; i < result.rolls.length; ++i)
		{
			var sub = document.createElement("DIV");
			sub.innerHTML = result.rolls[i].value;
			switch (result.tree.size)
			{
				case -52:
					sub.className = "dCard dCard" + sub.innerHTML.substr(0,1);
					sub.innerHTML = sub.innerHTML.substr(1);
					break;
				case -1:
					sub.className = "dF";
					sub.innerHTML = ["-","&nbsp;","+"][result.rolls[i].value+1];
					break;
				case 1:
					sub.className = "dU";
					break;
				case 4:
				case 6:
				case 8:
				case 10:
				case 12:
				case 20:
					sub.className = "d" + result.tree.size;
					break;
				default:
					sub.className = "dX";
			}
			if (result.rolls[i].used == false)
			{
				sub.className += " die_roll die_reject";
			}
			else if (result.rolls[i].ace == true)
			{
				sub.className += " die_roll die_ace";
			}
			else
			{
				sub.className += " die_roll";
			}
			
			node.appendChild(sub);
		}
		
		var sub = document.createElement("DIV");
		sub.innerHTML = result.value;
		sub.className = "die_total";
		node.appendChild(sub);
	}
}

DiceRoller.prototype.displayResult = function(result, node, formatting)
{
	var ui = popup;
	//if (format === 'iphone') { ui = new Popup("DIE ROLL", {x:0,y:40,w:320,h:150},{x:160,y:190}); }
	//else if (format === 'ipad') { ui = new Popup("DIE ROLL", {x:100,y:100,w:400,h:200},{x:300,y:200}); }
	for (var i = 0; i < result.length; ++i)
	{
		var node = document.createElement("DIV");
		node.className = "die_result_block";
		
		this.displayRoll(result[i].roll, node);
		
		node.lastChild.className += " die_final_total";
		
		var title = document.createElement("DIV");
		title.className = "die_title";
		node.insertBefore(title,node.firstChild);

		if (formatting && formatting.length > i)
		{
			var ttxt = formatting[i].replace(/%n/gi, result[i].notation).replace(/%t/gi, result[i].roll.value);
			title.innerHTML = ttxt;
		}
		else
		{
			title.innerHTML = result[i].notation;
		}
		
		ui.show(node);
	}
}

var Dice = new DiceRoller();
Dice.shuffleDeck(DiceRoller.standard_cards);

var __namedRolls = [];
function addNamedRolls(rolls)
{
	__namedRolls = __namedRolls.concat(rolls);
}

function addDiceRollAnchors(inString)
{
	var rolls = findDiceRolls(inString);

	for (var r = 0; r < __namedRolls.length; ++r)
	{
		for (var n = 0; n < __namedRolls[r].names.length; ++n)
		{
			var name = __namedRolls[r].names[n];
			var idx = inString.indexOf(name);
			if (idx >= 0)
			{
				rolls.push({
					text: name,
					notation: __namedRolls[r].notation(),
					start: idx,
					end: idx + name.length
				});
				break;
			}
		}
	}

	rolls.sort(function sortRolls(a, b) { return b.start - a.start; });

	for (var i = 0; i < rolls.length; ++i)
	{
		inString = inString.substr(0, rolls[i].start) +
			"<a class=\"inline-dice-roll\" href=\"javascript:rollDice('" + rolls[i].notation + "', ['" + rolls[i].text + "']);\">" +
			inString.substring(rolls[i].start, rolls[i].end) + "</a>" +
			inString.substr(rolls[i].end);
	}

	return inString;
}

function findDiceRolls(inString)
{
	//           (  3   )d(      6     )(           k2                   ) (     +    )((      ) (            )(         repeat                 )   +2   )
	var regex = /([0-9]*)d([0-9]+|u|f|c)(k[0-9]+|k[0-9]+l|d[0-9]+|r[0-9]+)?(\+\s*|-\s*)(([0-9]*)d([0-9]+|u|f|c)(k[0-9]+|k[0-9]+l|d[0-9]+|r[0-9]+)?|[0-9]+)/gi;

	var offset = 0;
	var results = [];

	var curResult = null;
	var matches = null;
	while (matches = regex.exec(inString))
	{
		if (curResult == null || // first match...
			(matches.index > curResult.end && inString.substr(curResult.end, matches.index).trim() != "")) // something in between this and the last...
			
		{
			curResult = {
				text: matches[0],
				notation: matches[0],
				start: matches.index,
				end: matches.index + matches[0].length
			};
			results.push(curResult);
		}
		else
		{
			curResult.text += matches[0];
			curResult.notation += matches[0];
			curResult.end += matches[0].length;
		}
	}

	return results;
}

function rollDice(notation,formatting)
{
	var parsed = Dice.parse(notation);
	//document.write("<br />result: " + JSON.stringify(parsed));
	var rolled = Dice.rollTree(parsed);
	//document.write("<br />result: " + JSON.stringify(rolled));
	
	Dice.displayResult(rolled, document.getElementById("dice_block"), formatting);
}
