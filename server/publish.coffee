Meteor.publish 'categories', ->
	share.Categories.find()

Meteor.publish 'energyRatings', ->
	share.EnergyRatings.find()

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