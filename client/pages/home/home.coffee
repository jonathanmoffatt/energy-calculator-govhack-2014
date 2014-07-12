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

getApplianceIndex = ->
	applianceIndex = Session.get 'appliance-index'
	if applianceIndex? then applianceIndex else 0

getHouseholdId = ->
	Session.get 'household-id'

getHousehold = ->
	share.Households.findOne getHouseholdId()

getAppliance = ->
	household = getHousehold()
	appliance = household.appliances[getApplianceIndex()]

setCategoryName = (categoryName) ->
	Session.set 'category-name', categoryName

getCategoryName = ->
	Session.get 'category-name'

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
	getBrands: ->
		[]
###
		category = getCategoryName()
		brands = []
		if category?
			ratings = share.EnergyRatings.find(Category: category).fetch()
			allBrands = _(ratings).map (r) -> r.Brand_Reg
			uniqueBrands = _(allBrands).uniq()
		brands
###

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
		applianceIndex = getApplianceIndex()
		categoryId = $('#uxApplianceCategory').val()
		category = share.Categories.findOne categoryId
		updates = {}
		updates["appliances.#{applianceIndex}.category"] = category
		share.Households.update householdId, $set: updates
		setCategoryName category.category
		true