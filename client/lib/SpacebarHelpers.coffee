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

UI.registerHelper 'dollars', (number) ->
	"$#{number.toFixed(2)}"

UI.registerHelper 'displayStars', (stars, category, hotStars, coldstars) ->
	if stars?
		if category == 'AirConditioner'
			i = 0
			html = ''
			##do hot stars
			if hotStars
				while i < parseInt(hotStars)
					html = html + '<span class="glyphicon glyphicon-star"></span>'
					i++
				wholeStar = hotStars % 1 == 0
				if !wholeStar
					html = html + '<span class="glyphicon glyphicon-star-empty"></span>'

				html = html + '(heating)</br>'
			else
				html = html + '(no heating ratings)</br>'

			##do cold stars
			if coldstars
				j = 0
				while j < parseInt(coldstars)
					html = html + '<span class="glyphicon glyphicon-star"></span>'
					j++
				wholeStar = coldstars % 1 == 0
				if !wholeStar
					html = html + '<span class="glyphicon glyphicon-star-empty"></span>'

				html = html + '(cooling)'
			else
				html = html + '(no cooling ratings)</br>'
			return html

		else
			i = 0
			html = ''
			console.log stars
			while i < parseInt(stars)
				html = html + '<span class="glyphicon glyphicon-star"></span>'
				i++
			wholeStar = stars % 1 == 0
			if !wholeStar
				html = html + '<span class="glyphicon glyphicon-star-empty"></span>'
			return html
	else
		''