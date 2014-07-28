Router.map ->
	@route 'admin',
		path: '/admin'
		template: 'admin'
		loadingTemplate: 'loading'
		waitOn: ->
			[
				this.subscribe('categories'),
				this.subscribe('all-appliances'),
				this.subscribe('tvs'),
				this.subscribe('dryers'),
				this.subscribe('fridges'),
				this.subscribe('monitors'),
				this.subscribe('dishwashers'),
				this.subscribe('airConditioners'),
				this.subscribe('washingMachines')
			]
		data: ->
			categories: share.Categories.find()

Template.admin.events =
	'click #uxUploadDatasetButton': ->
		categoryCollection = $('#uxCategory').val()
		clearExistingData = $('#uxClearExistingData').is(':checked')
		uploader = $("#uxDataUploader")
		_(uploader[0].files).each (file) ->
			fileReader = new FileReader()
			fileReader.onload = (file) ->
				Meteor.call 'adminUploadFile', categoryCollection, clearExistingData, file.srcElement.result, name, 'utf8'
			fileReader.readAsText file
		false
	'click #uxCreateCategoriesButton': ->
		Meteor.call 'adminCreateCategories'

Template.admin.helpers
	getCategoryCount: (categoryCollection) ->
		share[categoryCollection].find().count()
	getApplianceCount: ->
		share.Appliances.find().count()