Router.map ->
	@route 'admin',
		path: '/admin'
		template: 'admin'
		data: ->
			categories: share.Categories.find()

Template.admin.rendered = ->
	#$('#uxCategory').select2()

Template.admin.events =
	'click #uxUploadDatasetButton': ->
		categoryCollection = $('#uxCategory').val()
		uploader = $("#uxDataUploader")
		_(uploader[0].files).each (file) ->
			fileReader = new FileReader()
			fileReader.onload = (file) ->
				Meteor.call 'adminUploadFile', categoryCollection, file.srcElement.result, name, 'utf8'
			fileReader.readAsText file
		false
	'click #uxCreateCategoriesButton': ->
		Meteor.call 'adminCreateCategories'

Template.admin.helpers
	getCategoryCount: (categoryCollection) ->
		share[categoryCollection].find().count()
	getApplianceCount: ->
		share.Appliances.find().count()