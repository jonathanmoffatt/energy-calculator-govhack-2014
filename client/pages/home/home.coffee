Router.map ->
	@route 'home',
		path: '/:_id'
		template: 'home'
		loadingTemplate: 'loading'
		waitOn: ->
			householdId = @params._id
			[
				this.subscribe('household', householdId),
				Meteor.subscribe('categories'),
				Meteor.subscribe('appliances')
			]
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

getUsageLabel = (categoryName) ->
	switch categoryName
		when 'TV' then 'How many hours a day do you watch TV?'
		when 'Dryer' then 'How many loads of drying do you do each week?'
		when 'WashingMachine' then 'How many loads of washing do you do each week?'
		when 'Fridge' then null
		when 'Dishwasher' then 'How many times do you run the dishwasher each week?'
		when 'AirConditioner' then '---'
		else
			null

setUsageLabel = ->
	appliance = getCurrentAppliance()
	if appliance? and appliance.category?
		Session.set 'usage-label', getUsageLabel(appliance.category.name)
	else
		Session.set 'usage-label', null

showUsage = ->
	appliance = getCurrentAppliance()
	appliance.applianceId? and Session.get('usage-label')?


getAdjustedCEC = (usage, heatingUsage) ->
	applianceId = $('#uxModelNumber').val()
	categoryName = $('#uxApplianceCategory').val()
	selectedAppliance = share.Appliances.findOne({_id: applianceId})
	defaultCEC = selectedAppliance.CEC

	if categoryName == 'TV'
		adjustedCEC = share.GetTVCostAnnually(0.259, defaultCEC, usage)
	if categoryName == 'Dryer'
		adjustedCEC = share.GetDryerCostAnnually(0.259, defaultCEC, usage * 52)
	if categoryName == 'WashingMachine'
		adjustedCEC = share.GetWashingMachineCostAnnually(0.259, defaultCEC, usage * 52) #question is how many per week
	if categoryName == 'Dishwasher'
		adjustedCEC = share.GetDishwasherCostAnnually(0.259, defaultCEC, usage * 52)
	if categoryName == 'AirConditioner'
		coolInput = selectedAppliance.CoolingInputRate
		heatInput = selectedAppliance.HeatingInputRate
		adjustedCEC =  share.GetAirConCostAnnually(0.259, coolInput, usage, heatInput, heatingUsage)
	if categoryName == 'Fridge'
		adjustedCEC = defaultCEC
	adjustedCEC

isAirConditioner = ->
	getCurrentAppliance().category.name is 'AirConditioner'


Template.home.rendered = ->
	RefreshChart()
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
			category = share.Categories.findOne name: appliance.category.name
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
				'category.name': appliance.category.name
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
	showDoneButton: ->
		getCurrentAppliance().model?
	showUsage: ->
		showUsage() and not isAirConditioner()
	showAirConditionerUsage: ->
		showUsage() and isAirConditioner()
	getUsage: ->
		appliance = getCurrentAppliance()
		appliance.usage
	getCoolingUsage: ->
		if isAirConditioner()
			getCurrentAppliance().coolingUsage
		else
			''
	getHeatingUsage: ->
		if isAirConditioner()
			getCurrentAppliance().heatingUsage
		else
			''
	getUsageDescription: (appliance) ->
		if appliance? and appliance.category?
			switch appliance.category.name
				when 'TV' then "#{appliance.usage} hrs/day"
				when 'AirConditioner' then "#{appliance.coolingUsage}+#{appliance.heatingUsage} hrs/year"
				when 'Dryer', 'Dishwasher', 'WashingMachine' then "#{appliance.usage} times/week"
				when 'Fridge' then '-'
				else appliance.usage
		else
			''

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
		setUsageLabel()
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

		categoryName = $('#uxApplianceCategory').val()
		if categoryName == 'TV'
			usage = 10
		if categoryName == 'Dryer'
			usage = 1
		if categoryName == 'WashingMachine'
			usage = 7
		if categoryName == 'Dishwasher'
			usage = 7
		if categoryName == 'Fridge'
			usage = null

		if isAirConditioner()
			updates["appliances.#{applianceIndex}.coolingUsage"] = 200
			updates["appliances.#{applianceIndex}.heatingUsage"] = 200
			updates["appliances.#{applianceIndex}.adjustedCEC"] = parseFloat(getAdjustedCEC(200, 200))
		else
			updates["appliances.#{applianceIndex}.usage"] = parseFloat(usage)
			updates["appliances.#{applianceIndex}.adjustedCEC"] = parseFloat(getAdjustedCEC(usage))

		RefreshChart()
		share.Households.update householdId, $set: updates
		true
	'change #uxUsage': ->
		usage = $('#uxUsage').val()
		if usage
			householdId = getHouseholdId()
			applianceIndex = getApplianceIndex()
			updates = {}
			updates["appliances.#{applianceIndex}.usage"] = parseFloat(usage)
			updates["appliances.#{applianceIndex}.adjustedCEC"] = parseFloat(getAdjustedCEC(usage))
			share.Households.update householdId, $set: updates
			RefreshChart()
		true
	'change .aircon-usage': ->
		coolingUsage = parseFloat($('#uxCoolingUsage').val())
		heatingUsage = parseFloat($('#uxHeatingUsage').val())
		householdId = getHouseholdId()
		applianceIndex = getApplianceIndex()
		updates = {}
		updates["appliances.#{applianceIndex}.coolingUsage"] = parseFloat(coolingUsage)
		updates["appliances.#{applianceIndex}.heatingUsage"] = parseFloat(heatingUsage)
		updates["appliances.#{applianceIndex}.adjustedCEC"] = parseFloat(getAdjustedCEC(coolingUsage, heatingUsage))
		share.Households.update householdId, $set: updates
		RefreshChart()
		true

	# doing weird shit, so just make it invisible as no time to fix it and can just use the done button
	'click .add-appliance-button': ->
		showDataEntry true
		household = getHousehold()
		indexToAdd = 0
		if household? and household.appliances?
			# add at the end
			indexToAdd = household.appliances.length
		appliance =
			index: indexToAdd
		console.log "adding empty appliance with index #{indexToAdd}"
		share.Households.update household._id, $push:
			appliances: appliance
		setApplianceIndex indexToAdd
		true
	'click #uxDoneButton': ->
		showDataEntry false
		RefreshChart()
		false
	'click .edit-button': ->
		appliance = this
		console.log "switching to appliance #{appliance.index}"
		showDataEntry true
		setApplianceIndex appliance.index
		setUsageLabel()
		# don't know why this isn't working reactively, so do manually for now
		populate = ->
			$('#uxApplianceCategory').val(appliance.category.name)
			$('#uxBrand').val(appliance.brand)
			$('#uxModelNumber').val(appliance.applianceId)
		Meteor.setTimeout populate, 50
		true

# WHAT-IF AREA
Template.WhatIf.helpers
	anyAppliances: ->
		household = getHousehold()
		household? and household.appliances.length > 0


# RESULTS AREA

getRandomColors = (i) ->
	colors = [
		['#F7464A','#FF5A5E' ]
		['#46BFBD','#5AD3D1']
		['#FDB45C','#FFC870']
		['#B48EAD','#C69CBE']
		['#949FB1','#A8B3C5']
		['#4D5360','#616774']

	]

	colors[i % colors.length]



starHTML = (stars) ->
	i = 0
	html = ''
	console.log stars
	while i < parseInt(stars)
		html = html + '<span class="glyphicon glyphicon-star"></span>'
		i++

	wholeStar = stars % 1 == 0
	if !wholeStar
		html = html + '<span class="glyphicon glyphicon-star-empty"></span>'

	html

getChartData = ->
	household = getHousehold()

	data = []
	i = 0
	for a in household.appliances
		color = getRandomColors(i)
		if a.applianceId
			selectedAppliance = share.Appliances.findOne({_id: a.applianceId})
			stars = selectedAppliance.StarRating
			wholeStar = selectedAppliance.StarRating % 1 == 0

			data.push
				value: parseInt(a.adjustedCEC)
				label:  a.category.name + ': $' + parseInt(a.adjustedCEC) + '/year'
				color: color[0]
				highlight: color[1]
				title: a.category.name + '(' + a.model + ')'
				stars: parseInt(stars)
				costs: parseInt(a.adjustedCEC)
				halfStar: !wholeStar
				actualStars : stars
				starHTML : starHTML(stars)

		i++
	data

Template.PieChart.helpers
	chartData: ->
		getChartData()

RefreshChart = ->

	data = getChartData()
	$('#usagePieChart').replaceWith('<canvas id="usagePieChart" width="400" height="400"></canvas>')
	ctx = $("#usagePieChart")[0].getContext('2d')
	myPieChart = new Chart(ctx).Doughnut data,
		tooltipTemplate: "<%=label%>"
		tooltipEvents: ["mousemove", "touchstart", "touchmove"]


# take appliances
# for each appliance
#	value = CEC
#	color is random
#		highlight is random
#		label : name

###		data = [
			{
				value: 300,
				color: "#F7464A",
				highlight: "#FF5A5E",
				label: "BLAH BLAH BLAH?"
				labelColor: 'white'
				labelFontSize: '16'
			},
			{
				value: 50,
				color: "#46BFBD",
				highlight: "#5AD3D1"
				label: "Green"
				labelColor: 'white'
				labelFontSize: '16'
			},
			{
				value: 100,
				color: "#FDB45C"
				highlight: "#FFC870"
				label: "Black"
				labelColor: 'white'
				labelFontSize: '16'
			}
		]###




