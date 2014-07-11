Meteor.methods
	adminUploadFile: (category, blob, name, encoding) ->
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
			json = response.result
			share.EnergyRatings.remove Category: category
			_(json).each (record) ->
				record.Category = category
				share.EnergyRatings.insert record
			msg = "#{json.length} records were imported"
			console.log msg
			msg