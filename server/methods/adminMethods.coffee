Meteor.methods

	adminUploadFile: (categoryCollection, clearExistingData, blob, name, encoding) ->
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
			if clearExistingData
				collection.remove {}
			_(json).each (record) ->
				collection.insert record

			# put a list of brands against each category
			category = share.Categories.findOne collection: categoryCollection
			sortedByBrand = _(json).sortBy (r) -> r[category.brandField]
			allBrands = _(sortedByBrand).map (r) -> r[category.brandField]
			uniqueBrands = _(allBrands).uniq()
			share.Categories.update category._id, $set: brands: uniqueBrands


			# list of the common field names
			commonCECName = 'CEC'
			commonStarName = 'StarRating'
			commonSRI = 'SRI'

			addCommonFields = (currObj, record, CECRecordName, StarRecordName, SRIRecordName) ->
				if CECRecordName
					currObj[commonCECName] = parseFloat(record[CECRecordName])
				if StarRecordName
					currObj[commonStarName] = parseFloat(record[StarRecordName])
				if SRIRecordName
					currObj[commonSRI] = parseFloat(record[SRIRecordName])

			# create a record for every model with a standardised set of data
			setupAppliances = (category, record) ->
				appliance =
					category:
						name: category.name
						description: category.description
						collection: category.collection
					brand: record[category.brandField]
					model: record[category.modelField]
				if category.name == 'TV'
					addCommonFields(appliance, record, 'CEC', 'Star', 'SRI')
					appliance['TVStar2'] = parseFloat(record.Star2)
				if category.name == 'Dryer'
					addCommonFields(appliance, record, 'New CEC', 'New Star', 'New SRI')
				if category.name == 'Fridge'
					addCommonFields(appliance, record, 'CEC_', 'Star2009', 'SRI2009')
				if category.name == 'Dishwasher'
					addCommonFields(appliance, record, 'CEC_', 'New Star', 'New SRI')
				if category.name == 'WashingMachine'
					addCommonFields(appliance, record, 'CEC_', 'New Star', 'New SRI')
				if category.name == 'AirConditioner'
					appliance['AirCon_sri2010_cool'] = parseFloat(record["sri2010_cool"])
					appliance['AirCon_sri2010_heat'] = parseFloat(record["sri2010_heat"])
					appliance['AirCon_Star2010_Cool'] = parseFloat(record["Star2010_Cool"])
					appliance['AirCon_Star2010_Heat'] = parseFloat(record['Star2010_Heat'])
					appliance['CoolingInputRate'] = parseFloat(record['C-Power_Inp_Rated'])
					appliance['HeatingInputRate'] = parseFloat(record['H-Power_Inp_Rated'])
				share.Appliances.insert appliance

			if clearExistingData
				share.Appliances.remove 'category.collection': categoryCollection
			setupAppliances(category, record) for record in json

			cleared = if clearExistingData then ' after wiping the existing records' else ''
			msg = "#{json.length} records were imported into collection #{categoryCollection}#{cleared}"
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
		# let's not bother with monitors; most people use laptops these days
		#add 'Monitor', 'Computer Monitor', 'Monitors', 'Brand Name', 'Model Number'
		add 'Dishwasher', 'Dishwasher', 'Dishwashers', 'Brand', 'Model No'
		add 'AirConditioner', 'Air conditioner', 'AirConditioners', 'Brand', 'Model_No'
		add 'WashingMachine', 'Washing machine', 'WashingMachines', 'Brand', 'Model No'




