import read from './_read.imba'
import write from './_write.imba'
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

	def read data = {query\Object: {}, onsuccess\Function: undefined, onerror\Function: undefined}
		await read(connection,data.query,data.onsuccess,data.onerror,true)
	
	def write data = {records: undefined, onsuccess\Function: undefined, onerror\Function: undefined}
		await write(connection,data.records,data.onsuccess,data.onerror,uid)

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

	def read data = {query\Object: {}, onsuccess\Function: undefined, onerror\Function: undefined}
		await read(connection,data.query,data.onsuccess,data.onerror,false)
	
	def write data = {records: undefined, onsuccess\Function: undefined, onerror\Function: undefined}
		await write(connection,data.records,data.onsuccess,data.onerror,uid)

	# set listener for db events
	def subscribe options = {name\String: '', query\Object: {}, onupdate\Function: undefined, onerror\Function: undefined}
		subscriptions[options.name]! if subscriptions[options.name]
		
		subscriptions[options.name] = connection.subscribeQuery options.query, do(response)
			if response.error
				options.onerror(response.error.message) if options.onerror isa Function
			else
				options.onupdate(response.data) if options.onupdate isa Function
	
	def unsubscribe name\String = ''
		subscriptions[name]! if subscriptions[name]