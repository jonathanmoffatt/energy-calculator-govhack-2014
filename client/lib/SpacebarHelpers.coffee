UI.registerHelper 'iif', (condition, valueIfTrue, valueIfFalse) ->
	if condition then valueIfTrue else valueIfFalse

UI.registerHelper 'iifmatch', (value1, value2, resultIfTrue, resultIfFalse) ->
	if value1 is value2 then resultIfTrue else resultIfFalse

UI.registerHelper 'sessionIsTrue', (key) ->
	Session.get(key)

UI.registerHelper 'sessionIs', (key, value) ->
	Session.get(key) is value

UI.registerHelper 'getValueFromSession', (key) ->
	Session.get(key)

UI.registerHelper 'splitIntoParagraphs', (text) ->
	if text
		i = 1
		_(text.split('\n')).map (p) -> {number: i++, text: p}
	else
		[]

UI.registerHelper 'checkedIf', (condition) ->
	if condition then 'checked' else null

UI.registerHelper 'capitalise', (string) ->
	if string
		string.substr(0, 1).toUpperCase() + string.substr(1)