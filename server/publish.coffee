Meteor.publish 'categories', ->
	share.Categories.find()

Meteor.publish 'energyRatings', ->
	share.EnergyRatings.find()

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
