// a wrapper for knockout.js

var ko = require('knockout');
var view_model = {};

function createViewModel(cd, vm)
{
	function readProp(obj, prop) { return obj[prop]; }
	function writeProp(obj, prop, value) { obj[prop] = value; }

	for (var prop in cd)
	{
		var t = typeof(cd[prop]);
		if (t == 'string' || t == 'number' || t == 'boolean')
		{
			//vm[prop] = ko.computed({
			//	read: readProp.bind(undefined, cd, prop),
			//	write: writeProp.bind(undefined, cd, prop),
			//	owner: vm
			//});
			vm[prop] = ko.observable(cd[prop]);
		}
		else if (Array.isArray(cd[prop]))
		{
			var a = [];
			createViewModel(cd[prop], a);
			vm[prop] = ko.observableArray(a);
		}
		else
		{
			vm[prop] = {};
			createViewModel(cd[prop], vm[prop]);
		}
	}
}

global.init_dynamic = function init_dynamic()
{
	ko.bindingHandlers.divtext = {
		init: function(element, valueAccessor)
		{
			element.addEventListener('blur', function onBlur() 
			{
				var observable = valueAccessor();
				observable( this.innerHTML );
			});

			if (element.nodeName == "DIV" && 
				element.getAttribute("data-multiline") != "true")
			{
				// enforce single line behavior
			}
		},
		update: function(element, valueAccessor)
		{
			var value = ko.utils.unwrapObservable(valueAccessor());
			element.innerHTML = value;
		}
	};

	createViewModel(character_data, view_model);

	ko.applyBindings(view_model);
}

global.request_character_save = function request_character_save()
{
	window.webkit.messageHandlers["gamerkit.char.requestSave"].postMessage(character_data);
}