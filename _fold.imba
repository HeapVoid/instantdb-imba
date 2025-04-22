# --------------------------------------------------
# Folding one-to-one relations from array to object
# --------------------------------------------------

export def prefold query, folds
	prepare(query[Object.keys(query)[0]], '', folds)
	
export def postfold arr, folds
	return if !folds or !folds.length
	for item in arr
		fold(item, folds)

# ----------------------------------------------------
# gathers and removes fold commands from the query
# recursively proceeds all the query tree
# ----------------------------------------------------
export def prepare data, path = '', arr = []
	for own key,value of data
		if key == '$' and value..fold..length
			for child in value.fold
				arr.push("{path}.{child}")
			delete value.fold
		elif key != '$'
			arr = arr.concat(prefold(value,"{path}.{key}"))
	return arr

# ----------------------------------------------------
# joins the first array object instead of the array itself
# based on the list containing all the joining made in prepare
# ----------------------------------------------------
export def fold data, list, path = ''
	for own key, value of data when key != '$'
		const p = "{path}.{key}"
		if list.indexOf(p) != -1 
			if value..length == 1
				data[key] = value[0]
				fold(value[0], list, p) if value[0] isa Object
			elif value..length > 1
				console.log "InstantDB: seems that [{p}] is not a one-to-one relation."
			else
				delete data[key]
		elif value isa Array
			for item in value when item isa Object
				fold(item,list,p)
		elif value isa Object
			fold(value,list,p)

