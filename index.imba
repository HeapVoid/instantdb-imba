import read from './_read.imba'
import write from './_write.imba'
import {prefold, postfold} from './_fold.imba'
import Auth from './_auth.imba'

# ------------------------------------------
# Node or Bun code on the server
# ------------------------------------------
export class ServerIDB
	folding\boolean = true
	uid\Function
	connection

	def constructor conn, guid
		connection = conn
		uid = guid

	def read query = {query:{}, onsuccess:undefined, onerror:undefined}
		await read(connection,query.query,query.onsuccess,query.onerror,true,folding)
	
	def write records = {records:undefined, onsuccess:undefined, onerror:undefined}
		await write(connection,records.records,records.onsuccess,records.onerror,uid)

# ------------------------------------------
# Client working in the browser
# ------------------------------------------
export class ClientIDB
	folding\boolean = true
	connection
	uid\Function
	auth\Auth
	subscriptions = {}

	def constructor conn, guid
		connection = conn
		uid = guid
		auth = new Auth(connection, uid)

	def read query = {query:{}, onsuccess:undefined, onerror:undefined}
		await read(connection,query.query,query.onsuccess,query.onerror,false,folding)
	
	def write records = {records:undefined, onsuccess:undefined, onerror:undefined}
		await write(connection,records.records,records.onsuccess,records.onerror,uid)

	# set listener for db events
	def subscribe options = {name:'', query:{}, onupdate:undefined, onerror:undefined}
		subscriptions[options.name]! if subscriptions[options.name]
		
		let folds = []
		prefold(options.query, folds)
		
		subscriptions[options.name] = connection.subscribeQuery options.query, do(response)
			if response.error
				options.onerror(response.error.message) if options.onerror isa Function
			else
				postfold(response.data, folds)
				options.onupdate(response.data) if options.onupdate isa Function