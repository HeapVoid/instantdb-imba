# ------------------------------------
# Auth
# ------------------------------------
export default class Auth
	connection
	
	def constructor conn
		connection = conn
		
	# ------------------------------------
	# listen for changes in auth state
	# ------------------------------------
	def listen options = {onupdate:undefined, onerror:undefined}
		connection.subscribeAuth do(auth)
			if auth.error 
				options.onupdate(null) if options.onupdate isa Function
				options.onerror(auth.error.message) if options.onerror isa Function
			elif !auth.user
				options.onupdate(null) if options.onupdate isa Function
			elif auth.user
				options.onupdate(auth.user) if options.onupdate isa Function
			else
				console.log 'Instant DB Error: something went wrong during listening for auth'

	# ------------------------------------
	# Send magic code to specified email
	# ------------------------------------
	def code options = {email:'', onsuccess:undefined, onerror:undefined}
		if !options.email
			if options.onerror isa Function
				options.onerror!
			else
				console.log 'Instant DB Error: empty email for sending a code'
			return false

		try 
			let res = await connection.auth.sendMagicCode({ email:options.email })
			options.onsuccess(res) if options.onsuccess isa Function
			return true
		catch error
			options.onerror(error) if options.onerror isa Function
			return false

	# ------------------------------------
	# login with a magic code
	# ------------------------------------
	def login options = {email:'', code:'', onsuccess:undefined, onerror:undefined}
		if !options.email or !options.code
			if options.onerror isa Function
				options.onerror!
			else
				console.log 'Instant DB Error: empty email or code while login'
			return false

		try 
			await connection.auth.signInWithMagicCode({ email:options.email, code:options.code })
			options.onsuccess! if options.onsuccess isa Function
			return true
		catch error 
			options.onerror(error) if options.onerror isa Function
			return false

	# ------------------------------------
	# logout user from the system
	# ------------------------------------
	def logout options = {onerror:undefined, onsuccess:undefined}
		try 
			await connection.auth.signOut!
			options.onsuccess! if options.onsuccess isa Function
			return true
		catch error 
			options.onerror(error) if options.onerror isa Function
			return false
