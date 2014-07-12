Router.map ->
	@route 'home',
		path: '/:_id'
		template: 'home'
		loadingTemplate: 'loading'
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
	household = getHousehold()
	applianceIndex = getApplianceIndex()
	if household? and household.appliances? and applianceIndex isnt -1
		household.appliances[getApplianceIndex()]
	else
		category: null

getApplianceIndex = ->
	applianceIndex = Session.get 'appliance-index'
	if applianceIndex? then applianceIndex else -1

setApplianceIndex = (index) ->
	Session.set 'appliance-index', index

getHouseholdId = ->
	Session.get 'household-id'

getHousehold = ->
	share.Households.findOne getHouseholdId()

showDataEntry = (show) ->
	Session.set 'show-data-entry', show


Template.home.rendered = ->
	#$('select').select2()

Template.home.helpers
	anyAppliances: ->
		household = getHousehold()
		household? and household.appliances.length > 0
	isCategorySelected: ->
		categoryName = this
		appliance = getCurrentAppliance()
		if appliance.category? and appliance.category.name is categoryName then 'selected' else null
	isBrandSelected: ->
		brand = this
		appliance = getCurrentAppliance()
		if appliance? and appliance.brand is brand then 'selected' else null
	showBrands: ->
		getCurrentAppliance().category?
	getBrands: ->
		appliance = getCurrentAppliance()
		if appliance.category?
			category = share.Categories.findOne name:appliance.category.name
			category.brands
		else
			[]
	showModelNumbers: ->
		getCurrentAppliance().brand?
	getAppliances: ->
		appliance = getCurrentAppliance()
		brand = appliance.brand
		if brand?
			criteria =
				'category.name' : appliance.category.name
				brand: brand
			options =
				fields:
					_id: 1
					model: 1
			share.Appliances.find(criteria, options).fetch()
		else
			[]
	isModelSelected: ->
		appliance = this
		currentAppliance = getCurrentAppliance()
		if appliance._id is currentAppliance._id then 'selected' else null
	showDataEntry: ->
		Session.get 'show-data-entry'

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
		console.log "changing appliance category to #{categoryName}"
		category = share.Categories.findOne name: categoryName
		householdId = getHouseholdId()
		applianceIndex = getApplianceIndex()
		categoryInfo =
			name: category.name
			description: category.description
			collection: category.collection
		updates = {}
		updates["appliances.#{applianceIndex}.category"] = categoryInfo
		share.Households.update householdId, $set: updates
		true
	'change #uxBrand': ->
		brand = $('#uxBrand').val()
		console.log "changing brand to #{brand}"
		householdId = getHouseholdId()
		applianceIndex = getApplianceIndex()
		updates = {}
		updates["appliances.#{applianceIndex}.brand"] = brand
		share.Households.update householdId, $set: updates
		true
	'change #uxModelNumber': ->
		applianceId = $('#uxModelNumber').val()
		model = $("#uxModelNumber option[value='#{applianceId}']").text()
		console.log "changing model to #{model} and applianceId to #{applianceId}"
		householdId = getHouseholdId()
		applianceIndex = getApplianceIndex()
		updates = {}
		updates["appliances.#{applianceIndex}.model"] = model
		updates["appliances.#{applianceIndex}.applianceId"] = applianceId
		share.Households.update householdId, $set: updates
		true
	'click #uxAddApplianceButton': ->
		showDataEntry true
		household = getHousehold()
		indexToAdd = 0
		if household? and household.appliances?
			# add at the end
			indexToAdd = household.appliances.length
		appliance =
			index: indexToAdd
		console.log "adding empty appliance with index #{indexToAdd}"
		share.Households.update household._id, $push: appliances: appliance
		setApplianceIndex indexToAdd

	'click .edit-button': ->
		appliance = this
		console.log "switching to appliance #{appliance.index}"
		showDataEntry true
		setApplianceIndex appliance.index
		# don't know why this isn't working reactively, so do manually for now
		$('#uxApplianceCategory').val(appliance.category.name)
		$('#uxBrand').val(appliance.brand)
		$('#uxModelNumber').val(appliance.model)
		true