class ListingTable extends EntitySetWidget

	render: (view) ->
		DataManager.getEntities @entityType.resource, (entities) =>
			@drawTable(@entityType, entities, view)

	drawTable: (entityType, entities, view) ->
		title = $("<h2>")
		title.append entityType.name
		view.append title 
		addButton = $("<button>")
		addButton.append "Add"
		addButton.click =>
			formWidget = RenderingEngine.getWidget entityType, null, 'form'
			formWidget.entityType = entityType
			RenderingEngine.pushWidget this
			formWidget.render View.emptyPage()
		view.append addButton
		@table = $("<table>")
		view.append @table
		@buildTableHead(entityType.propertiesType, @table);
		@buildTableBody(entityType, entities, @table)

	buildTableHead: (properties, table) ->
		thead = $("<thead>");
		table.append thead
		trHead = $("<tr>");
		trHead.attr "id", "properties"
		thead.append trHead
		properties.forEach (property) ->
			thHead = $("<th>#{property.name}</th>")
			trHead.append thHead

	buildTableBody: (entityType, entities, table) ->
		if(entities.length > 0)
			tbody = $("<tbody>");
			tbody.attr "id", "instances"
			table.append tbody
			entities.forEach (entity) =>
				@buildTableLine(entity, entityType, tbody)
		else
			table.append "There are not instances"

	buildTableLine: (entity, entityType, tbody) ->
		trbody = $("<tr>")
		trbody.attr "id", "instance_" + entity.id
		tbody.append trbody
		entityType.propertiesType.forEach (propertyType) =>
			td  = $("<td>");
			td.attr "id", "entity_" + entity.id + "_property_" + propertyType.name
			widget = RenderingEngine.getWidget entityType, propertyType.type, 'property'
			widget.propertyType = propertyType
			widget.property = entity[propertyType.name] 
			widget.render td
			trbody.append td
		
		editButton = $("<button>")
		editButton.append "Edit"
		editButton.click =>
			formWidget = RenderingEngine.getWidget entityType, null, 'form'
			formWidget.entityType = entityType
			formWidget.entityID = entity.id
			RenderingEngine.pushWidget this
			formWidget.render View.emptyPage()
		td  = $("<td>");
		td.append editButton
		trbody.append td
		
		deleteButton = $("<button>")
		deleteButton.append "Delete"
		self = this
		deleteButton.click ->
			DataManager.deleteEntity(entityType.resource, entity.id)
			.done (data, textStatus, jqXHR) =>
				
				self.render(View.emptyPage(), entityType)
			.fail (jqXHR, textStatus, errorThrown) =>
				alert("Ocorreu o erro: " + status)
		td  = $("<td>");
		td.append deleteButton
		trbody.append td

return new ListingTable