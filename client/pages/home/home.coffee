Router.map ->
	@route 'home',
		path: '/:_id'
		template: 'home'
		waitOn: ->
			householdId = @params._id
			this.subscribe('household', householdId)
		data: ->
			household: share.Households.findOne(@params._id)
			categories: share.Categories.find()
		onAfterAction: ->
			householdId = @params._id
			Session.set 'household-id', householdId

getCurrentAppliance = ->
	appliance = Session.get 'current-appliance'
	if not appliance?
		appliance =
			category: null
	appliance

setCurrentAppliance = (appliance) ->
	Session.set 'current-appliance', appliance

getApplianceIndex = ->
	applianceIndex = Session.get 'appliance-index'
	if applianceIndex? then applianceIndex else -1

setApplianceIndex = (index) ->
	Session.set 'appliance-index', index

getHouseholdId = ->
	Session.get 'household-id'

getHousehold = ->
	share.Households.findOne getHouseholdId()

getAppliance = ->
	household = getHousehold()
	if household?
		household.appliances[getApplianceIndex()]
	else
		category: null

Template.home.rendered = ->
	#$('select').select2()

Template.home.helpers
	anyAppliances: ->
		household = getHousehold()
		household? and household.appliances.length > 0
	isCategorySelected: ->
		category = this
		household = getHousehold()
		selected = household? and household.appliances[getApplianceIndex()].category._id is category._id
		if selected
			console.log "selected #{category.category}"
		if selected then 'selected' else null
	showBrands: ->
		getAppliance().category?
	getBrands: ->
		appliance = getAppliance()
		if appliance.category?
			category = share.Categories.findOne name:appliance.category.name
			category.brands
		else
			[]

Template.home.events =
	'click a': (event) ->
		$anchor = $(event.currentTarget)
		href = $anchor.attr('href')
		isInternalLink = href.lastIndexOf('#', 0) is 0
		if isInternalLink
			$('html, body').stop().animate({scrollTop: $(href).offset().top}, 1500, 'easeInOutExpo')
		not isInternalLink
	'change #uxApplianceCategory': ->
		categoryName = $('#uxApplianceCategory').val()
		category = share.Categories.findOne name: categoryName
		appliance = getCurrentAppliance()
		appliance =
			category:
				name: category.name
				description: category.description
				collection: category.collection
		householdId = getHouseholdId()
		applianceIndex = getApplianceIndex()
		if applianceIndex is -1
			share.Households.update householdId, $push: appliances: appliance
			setApplianceIndex 0
		else
			updates = {}
			updates["appliances.#{applianceIndex}"] = appliance
			share.Households.update householdId, $set: updates
		true