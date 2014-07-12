Meteor.startup ->
	add = (category, description, collection) ->
		share.Categories.insert
			name: category
			description: description
			collection: collection
	if share.Categories.find().count() is 0
		add 'TV', 'TV', 'Tvs'
		add 'Dryer', 'Clothes Dryer', 'Dryers'
		add 'Fridge', 'Fridge', 'Fridges'
		add 'Monitor', 'Computer Monitor', 'Monitors'
		add 'Dishwasher', 'Dishwasher', 'Dishwashers'
		add 'AirConditioner', 'Air conditioner', 'AirConditioners'
		add 'WashingMachine', 'Washing machine', 'WashingMachines'