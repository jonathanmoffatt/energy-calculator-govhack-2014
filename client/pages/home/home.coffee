Router.map ->
	@route 'home',
		path: '/'
		template: 'home'
		data: ->
			categories: share.Categories.find()

getHouseholdId = ->
	Session.get 'householdId'

Template.home.rendered = ->
	$('select').select2()

Template.home.events =
	'click a': (event) ->
		$anchor = $(event.currentTarget)
		href = $anchor.attr('href')
		isInternalLink = href.lastIndexOf('#', 0) is 0
		if isInternalLink
			$('html, body').stop().animate({scrollTop: $(href).offset().top}, 1500, 'easeInOutExpo')
		not isInternalLink
	'change #uxApplianceCategory': ->
		householdId = getHouseholdId()
		if not householdId?
			householdId = share.Households.insert created: new Date()
			Session.set 'householdId', householdId
			console.log "created household #{householdId}"
