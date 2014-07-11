Router.map ->
	@route 'home',
		path: '/'
		template: 'home'

Template.home.events =
	'click a': (event) ->
		$anchor = $(event.currentTarget)
		href = $anchor.attr('href')
		isInternalLink = href.lastIndexOf('#', 0) is 0
		if isInternalLink
			$('html, body').stop().animate({scrollTop: $(href).offset().top}, 1500, 'easeInOutExpo')
		not isInternalLink

