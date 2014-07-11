Meteor.startup ->
	add = (category, description) ->
		share.Categories.insert
			category: category
			description: description
	if share.Categories.find().count() is 0
		add 'TV', 'TVs'
		add 'Dryer', 'Dryers'
		add 'Fridge', 'Fridges'
		add 'Monitor', 'Monitors'
		add 'Dishwasher', 'Dishwashers'
		add 'AirConditioner', 'Air conditioners'
		add 'WashingMachine', 'Washing machines'