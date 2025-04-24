# --------------------------------------------------
# Request information from the instant DB
# Folding allows to connect one-to-one links as objects not arrays
# --------------------------------------------------

export default def read connection, query, onsuccess, onerror, admin = false
	return if !connection or !query

	if !Object.keys(query).length
		console.log "InstantDB Error: empty query."
		return false
	elif Object.keys(query).length > 1
		console.log "InstantDB Error: query has several root keys."
		return false
	
	const namespace = Object.keys(query)[0]
	
	let result = []
	try
		result = admin ? (await connection.query(query))[namespace] : (await connection.queryOnce(query)).data[namespace]
		onsuccess(result) if onsuccess isa Function
	catch err
		onerror(err) if onerror isa Function
	
	return result
