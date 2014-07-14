Router.map ->
	@route 'admin',
		path: '/admin'
		template: 'admin'
		loadingTemplate: 'loading'
		waitOn: ->
			[
				Meteor.subscribe('categories'),
				Meteor.subscribe('appliances'),
				Meteor.subscribe('tvs'),
				Meteor.subscribe('dryers'),
				Meteor.subscribe('fridges'),
				Meteor.subscribe('monitors'),
				Meteor.subscribe('dishwashers'),
				Meteor.subscribe('airConditioners'),
				Meteor.subscribe('washingMachines')
			]
		data: ->
			categories: share.Categories.find()

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