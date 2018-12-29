require "kemal"
require "kemal-session"

require "authd"

macro add_authd_cli_options(authd)
	Kemal.config.extra_options do |parser|
		parser.on "-k file", "--jwt-key file", "Provides the JWT key for authd." do |file|
			authd.key = File.read(file).chomp
		end
	end
end

macro add_authd_middleware(authd)
	class HTTP::Server::Context
		property authd_user : AuthD::User? = nil
	end

	# FIXME: Make that a Middleware, maybe?
	class AuthDMiddleware < Kemal::Handler
		def initialize(@authd : AuthD::Client)
		end

		def call(context)
			token = context.session.string? "token"

			if token
				user, meta = @authd.decode_token token

				context.authd_user = user
			end

			call_next context
		end
	end

	add_handler AuthDMiddleware.new authd
end

