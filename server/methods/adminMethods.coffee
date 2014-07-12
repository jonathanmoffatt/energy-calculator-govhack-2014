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
			json = response.result
			collection = share[categoryCollection]
			collection.remove {}
			_(json).each (record) ->
				collection.insert record
			msg = "#{json.length} records were imported into collection #{categoryCollection}"
			console.log msg
			msg
