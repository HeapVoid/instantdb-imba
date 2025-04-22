# --------------------------------
# build a transaction
# --------------------------------
def transaction connection, record, uid
	record.id = uid! if record.action == 'create'
	record.data ||= {}

	if !record.action
		console.log "Inner error: for DB transaction no action was provided"
	elif !record.table
		console.log "Inner error: for DB transaction ({record.action}) no table was provided"
	elif !record.id
		console.log "Inner error: for DB transaction ({record.action}) no record ID was provided"
	elif record.action == 'link' and (!record.links or !Object.keys(record.links).length)
		console.log "Inner error: for DB transaction (link) no links were provided"
	else		
		let transaction = connection.tx[record.table][record.id]
		transaction = transaction.ruleParams({knownDocId: record.secret}) if record.secret
		transaction = transaction.update(record.data) if record.action == 'create'
		transaction = transaction.merge(record.data) if record.action == 'update'
		transaction = transaction.delete! if record.action == 'delete'
		transaction = transaction.link(record.links) if record.links and Object.keys(record.links).length and record.action in ['create', 'update', 'link']
		transaction = transaction.unlink(record.links) if record.links and Object.keys(record.links).length and record.action == 'unlink'
		return transaction
	return undefined

# --------------------------------
# run transactions in database
# --------------------------------
# await write(db,records,onerror,onsuccess,uid)
export default def write connection, records, onsuccess, onerror, uid
	return if !connection or !records or !(uid isa Function)

	let transactions = records
	
	if transactions isa Array
		for tx in transactions
			tx = transaction(connection, tx, uid)
	else
		transactions = transaction(connection, transactions, uid)
	
	try
		let result = await connection.transact(transactions)
		onsuccess(result) if onsuccess isa Function
		return true
	catch error
		onerror(error) if onerror isa Function
		return false