Meteor.methods

	adminUploadFile: (categoryCollection, blob, name, encoding) ->
		Converter = Meteor.require('csvtojson').core.Converter
		csvConverter = new Converter constructResult:true
		response = Async.runSync (done) ->
			csvConverter.fromString blob, (err, json) ->
				done err, json
		err = response.error;
		if (err)
			console.log "ERROR: #{err}"
			err
		else
			# import the raw data
			json = response.result
			collection = share[categoryCollection]
			collection.remove {}
			_(json).each (record) ->
				collection.insert record

			# put a list of brands against each category
			category = share.Categories.findOne collection: categoryCollection
			sortedByBrand = _(json).sortBy (r) -> r[category.brandField]
			allBrands = _(sortedByBrand).map (r) -> r[category.brandField]
			uniqueBrands = _(allBrands).uniq()
			share.Categories.update category._id, $set: brands: uniqueBrands

			# create a record for every category/brand combination, containing all the models
			setupAppliances = (category, record) ->
				appliance =
					category:
						name: category.name
						description: category.description
						collection: category.collection
					brand: record[category.brandField]
					model: record[category.modelField]
				share.Appliances.insert appliance
			share.Appliances.remove 'category.collection': categoryCollection
			setupAppliances(category, record) for record in json

			msg = "#{json.length} records were imported into collection #{categoryCollection}"
			console.log msg
			msg

	adminCreateCategories: ->
		share.Categories.remove {}
		add = (category, description, collection, brandField, modelField) ->
			share.Categories.insert
				name: category
				description: description
				collection: collection
				brandField: brandField
				modelField: modelField
		add 'TV', 'TV', 'Tvs', 'Brand_Reg', 'Model_No'
		add 'Dryer', 'Clothes Dryer', 'Dryers', 'Brand', 'Model No'
		add 'Fridge', 'Fridge', 'Fridges', 'Brand', 'Model No'
		add 'Monitor', 'Computer Monitor', 'Monitors', 'Brand Name', 'Model Number'
		add 'Dishwasher', 'Dishwasher', 'Dishwashers', 'Brand', 'Model No'
		add 'AirConditioner', 'Air conditioner', 'AirConditioners', 'Brand', 'Model_No'
		add 'WashingMachine', 'Washing machine', 'WashingMachines', 'Brand', 'Model No'


