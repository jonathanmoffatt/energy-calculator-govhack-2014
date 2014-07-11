Meteor.publish 'categories', ->
	share.Categories.find()

Meteor.publish 'energyRatings', ->
	criteria = {}
	options =
		fields:
			Brand_Reg: 1
			Model_No: 1
			Category: 1
	#share.EnergyRatings.find criteria, options
	share.EnergyRatings.find criteria, options

Meteor.publish 'basicEnergyRatings', (category) ->
	criteria = Category: category
	options =
		fields:
			Brand_Reg: 1
			Model_No: 1
			Category: 1
	share.EnergyRatings.find criteria, options

Meteor.publish 'household', (householdId) ->
	share.Households.find _id: householdId

Meteor.publish 'households', ->
	share.Households.find()

share.Categories.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.EnergyRatings.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.Households.allow
	insert: ->
		true
	remove: ->
		false
	update: ->
		true