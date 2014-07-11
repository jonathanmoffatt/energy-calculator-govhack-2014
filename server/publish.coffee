Meteor.publish 'categories', ->
	share.Categories.find()

Meteor.publish 'energyRatings', ->
	share.EnergyRatings.find()

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