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
		categoryName = this
		appliance = getCurrentAppliance()
		appliance.category? and appliance.category.name is categoryName
	isBrandSelected: ->
		brand = this
		appliance = getCurrentAppliance()
		appliance? and appliance.brand is brand
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
		setCurrentAppliance appliance
		true
	'change #uxBrand': ->
		brand = $('#uxBrand').val()
		householdId = getHouseholdId()
		applianceIndex = getApplianceIndex()
		updates = {}
		updates["appliances.#{applianceIndex}".brand] = brand
		share.Households.update householdId, updates
		true
	'click .edit-button': ->
		appliance = this
		applianceIndex = _(getHousehold().appliances).indexOf appliance
		setApplianceIndex applianceIndex
		setCurrentAppliance appliance
		true