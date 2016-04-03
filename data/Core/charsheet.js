
var mouseWidget = null;
var expectingToken = null;

var widgetConstructors = {
	'pips': function PipsWidget(node)
	{
		var onPip = "&#x26ab;";
		var offPip = "&#x26aa;";
		var max = parseInt(node.getAttribute("data-max"));
		var readonly = node.hasAttribute("data-readonly") &&
			(node.getAttribute("data-readonly") == "true" ||
			 node.getAttribute("data-readonly") == "");

		var pips_container = document.createElement("DIV");
		pips_container.className = "pips-container";

		var mouseX;
		var step = 25;
		node.onmousedown = function mouseDown(event)
		{
			if (event.which == 1)
			{
				mouseWidget = node;
				mouseX = event.pageX;

				node.onmousemove = function mouseMove(event)
				{
					if (mouseWidget === node)
					{
						var delta = event.pageX - mouseX;
						//console.log("delta", delta)
						if (delta <= -step)
						{
							decrease();
							mouseX -= step;
						}
						else if (delta >= step)
						{
							increase();
							mouseX += step;
						}
					}
				}
			}
		}

		function setPips()
		{
			var value = parseInt(node.getAttribute("data-value"));
			pips_container.innerHTML = Array(value+1).join(onPip) + Array(max-value+1).join(offPip);
		}

		function decrease(event)
		{
			if (event)
				{ event.preventDefault(); }

			var value = parseInt(node.getAttribute("data-value"));
			if (value > 0)
			{
				node.setAttribute("data-value", --value);
			}
			setPips();
		}

		function increase(event)
		{
			if (event)
				{ event.preventDefault(); }

			var value = parseInt(node.getAttribute("data-value"));
			if (value < max)
			{
				node.setAttribute("data-value", ++value);
			}
			setPips();
		}

		if (!readonly)
		{
			var downbutton = document.createElement("DIV");
			downbutton.className = "pips-down";
			downbutton.innerHTML = "&#x276e;";
			downbutton.onclick = decrease;

			node.appendChild(downbutton);
		}

		node.appendChild(pips_container);

		if (!readonly)
		{
			var upbutton = document.createElement("DIV");
			upbutton.className = "pips-up";
			upbutton.innerHTML = "&#x276f;";
			upbutton.onclick = increase;

			node.appendChild(upbutton);
		}

		setPips();
	},
	'spinner': function SpinnerWidget(node)
	{
		var max = node.hasAttribute("data-max")?parseInt(node.getAttribute("data-max")):999999;

		var readonly = node.hasAttribute("data-readonly") &&
			(node.getAttribute("data-readonly") == "true" ||
			 node.getAttribute("data-readonly") == "");

		var value_container = document.createElement("DIV");
		value_container.className = "value-container";

		var mouseX;
		var step = 25;
		node.onmousedown = function mouseDown(event)
		{
			if (event.which == 1)
			{
				mouseWidget = node;
				mouseX = event.pageX;

				node.onmousemove = function mouseMove(event)
				{
					if (mouseWidget === node)
					{
						var delta = event.pageX - mouseX;
						//console.log("delta", delta)
						if (delta <= -step)
						{
							decrease();
							mouseX -= step;
						}
						else if (delta >= step)
						{
							increase();
							mouseX += step;
						}
					}
				}
			}
		}

		function setValue()
		{
			var value = parseInt(node.getAttribute("data-value"));
			value_container.innerHTML = value;
		}

		function decrease(event)
		{
			if (event)
				{ event.preventDefault(); }

			var value = parseInt(node.getAttribute("data-value"));
			if (value > 0)
			{
				node.setAttribute("data-value", --value);
			}
			setValue();
		}

		function increase(event)
		{
			if (event)
				{ event.preventDefault(); }

			var value = parseInt(node.getAttribute("data-value"));
			if (value < max)
			{
				node.setAttribute("data-value", ++value);
			}
			setValue();
		}

		if (!readonly)
		{
			var downbutton = document.createElement("DIV");
			downbutton.className = "spinner-down";
			downbutton.innerHTML = "&#x276e;";
			downbutton.onclick = decrease;

			node.appendChild(downbutton);
		}

		node.appendChild(value_container);

		if (!readonly)
		{
			var upbutton = document.createElement("DIV");
			upbutton.className = "spinner-up";
			upbutton.innerHTML = "&#x276f;";
			upbutton.onclick = increase;

			node.appendChild(upbutton);
		}

		setValue();	
	},
	'pages': function PagesWidget(node)
	{
		var minWidth = parseInt(node.getAttribute('data-min-width'));

		node.style.display = "block";
		node.style.overflowX = "auto";
		node.style["-webkit-overflow-scrolling"] = "touch";

		var canvas = document.createElement('DIV');
		canvas.className = "pages-canvas";
		canvas.style.paddingLeft = "10px";

		var children = [];

		while (node.firstElementChild)
		{
			node.firstElementChild.style.float = "left";
			node.firstElementChild.style.paddingRight = 
			node.firstElementChild.style.paddingLeft = "10px";
			children.push(node.firstElementChild);
			canvas.appendChild(node.firstElementChild);
		}

		children.forEach(function (c)
			{ c.style.width = (100/children.length) + "%"; });

		node.appendChild(canvas);

		function resize()
		{
			var w = node.clientWidth;
			var num = Math.floor(w / minWidth);
			canvas.style.width = Math.max(100, (children.length / num * 100)) + "%";
		}

		window.addEventListener('resize', resize);

		resize();
	},
	'token': function TokenWidget(node)
	{
		node.addEventListener('click', function _tokenChange()
		{
			expectingToken = node;
			requestNewToken();
		});
	}
}

function updateExpectedToken(newImage)
{
	if (expectingToken)
	{
		expectingToken.setAttribute('src', "data:image/jpeg;base64," + newImage);
		expectingToken = null;
	}
}


function createWidgets()
{
	if ('characterSheetReady' in window)
		{ characterSheetReady(); }

	var popup = document.createElement("DIV");
	popup.className = 'popup-screen';
	popup.style.display = "none";

	popup.inner = document.createElement("DIV");
	popup.inner.className = 'popup';
	popup.appendChild(popup.inner);

	popup.inner.addEventListener('click', function consume(event)
		{ event.stopPropagation(); });

	popup.show = function show(contents)
	{
		var close = function close()
		{
			popup.removeEventListener('click', close);
			popup.inner.removeChild(contents);
			popup.style.display = "none";
		}

		popup.inner.appendChild(contents);
		popup.addEventListener('click', close);
		popup.style.display = "block";
	}

	document.body.appendChild(popup);
	window.popup = popup;

	// set up document-wide mouse events
	document.body.onmousemove = function onDocMouseMove(event)
	{
		if (mouseWidget != null)
		{
			if (mouseWidget.onmousemove)
				{ mouseWidget.onmousemove(event); }
			event.preventDefault();
		}
	}

	document.body.onmouseup = function onDocMouseUp(event)
	{
		if (mouseWidget != null)
		{
			if (mouseWidget.onmouseup)
				{ mouseWidget.onmouseup(event); }
			event.preventDefault();
			mouseWidget = null;
		}
	}

	// create widgets
	var list = document.body.querySelectorAll("[data-widget]");
	Array.prototype.forEach.call(list, function setupWidget(node)
	{
		var w = node.getAttribute("data-widget");
		if (w in widgetConstructors)
		{
			widgetConstructors[w](node);
		}
	});

	if ('rollDice' in window)
	{
		var rolls = document.body.querySelectorAll("[data-roll]");
		Array.prototype.forEach.call(rolls, function setupRoll(node)
		{
			node.addEventListener('click', function clickRoll()
			{
				var notation = node.getAttribute('data-roll').replace("*", parseInt(node.innerHTML));
				rollDice(notation);
			});
		});

		rolls = document.body.querySelectorAll("[data-has-dice-rolls]");
		Array.prototype.forEach.call(rolls, function anchorRolls(node)
		{
			node.innerHTML = addDiceRollAnchors(node.innerHTML);
		});
	}
}

