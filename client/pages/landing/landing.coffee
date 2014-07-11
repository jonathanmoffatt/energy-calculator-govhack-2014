Router.map ->
	@route 'landing',
		path: '/'
		onAfterAction: ->
			console.log "On landing page; creating a household and redirecting"
			householdId = share.Households.insert
				created: new Date()
				appliances: []
			Session.set 'household-id', householdId
			Router.go 'home', _id: householdId

