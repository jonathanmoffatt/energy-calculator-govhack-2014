Router.map ->
	@route 'admin',
		path: '/admin'
		template: 'admin'
		data: ->
			categories: share.Categories.find()

Template.admin.rendered = ->
	$('#uxCategory').select2()

Template.admin.events =
	'click #uxUploadDatasetButton': ->
		category = $('#uxCategory').val()
		uploader = $("#uxDataUploader")
		_(uploader[0].files).each (file) ->
			fileReader = new FileReader()
			fileReader.onload = (file) ->
				Meteor.call 'adminUploadFile', category, file.srcElement.result, name, 'utf8'
				alert 'Uploaded!'
			fileReader.readAsText file
		false

Template.admin.helpers
	getCategoryCount: (category) ->
		share.EnergyRatings.find(Category: category).count()