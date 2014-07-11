Router.map ->
	@route 'home',
		path: '/:_id'
		template: 'home'
		data: ->
			household = if @params._id? then share.Households.findOne(@params._id) else {}
			result =
				household: household 
				categories: share.Categories.find()
			result
		onAfterAction: ->
			householdId = @params._id
			Session.set 'household-id', householdId

getHouseholdId = ->
	Session.get 'household-id'

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