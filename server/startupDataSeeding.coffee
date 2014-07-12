Meteor.startup ->
	add = (category, description, collection, brandField) ->
		share.Categories.insert
			name: category
			description: description
			collection: collection
			brandField: brandField
	if share.Categories.find().count() is 0
		add 'TV', 'TV', 'Tvs', 'Brand_Reg'
		add 'Dryer', 'Clothes Dryer', 'Dryers', 'Brand'
		add 'Fridge', 'Fridge', 'Fridges', 'Brand'
		add 'Monitor', 'Computer Monitor', 'Monitors', 'Brand Name'
		add 'Dishwasher', 'Dishwasher', 'Dishwashers', 'Brand'
		add 'AirConditioner', 'Air conditioner', 'AirConditioners', 'Brand'
		add 'WashingMachine', 'Washing machine', 'WashingMachines', 'Brand'