Meteor.publish 'categories', ->
	share.Categories.find()

Meteor.publish 'household', (householdId) ->
	share.Households.find _id: householdId

Meteor.publish 'households', ->
	share.Households.find()

Meteor.publish 'tvs', ->
	criteria = {}
	options =
		fields:
			_id: 1
	share.Tvs.find criteria, options

Meteor.publish 'dryers', ->
	criteria = {}
	options =
		fields:
			_id: 1
	share.Dryers.find criteria, options

Meteor.publish 'fridges', ->
	criteria = {}
	options =
		fields:
			_id: 1
	share.Fridges.find criteria, options

Meteor.publish 'monitors', ->
	criteria = {}
	options =
		fields:
			_id: 1
	share.Monitors.find criteria, options

Meteor.publish 'dishwashers', ->
	criteria = {}
	options =
		fields:
			_id: 1
	share.Dishwashers.find criteria, options

Meteor.publish 'airConditioners', ->
	criteria = {}
	options =
		fields:
			_id: 1
	share.AirConditioners.find criteria, options

Meteor.publish 'washingMachines', ->
	criteria = {}
	options =
		fields:
			_id: 1
	share.WashingMachines.find criteria, options

share.Categories.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.Appliances.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.Tvs.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.Dryers.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.Fridges.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.Monitors.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.Dishwashers.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.AirConditioners.deny
	insert: ->
		true
	remove: ->
		true
	update: ->
		true

share.WashingMachines.deny
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