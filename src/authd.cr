require "digest"

require "kemal"
require "kemal-session"

require "authd"

# FIXME: This is the most critical part to deduplicate.
def main_template(env, **attrs, &block)
	user = env.authd_user

	page_title = attrs.fetch :title, nil

	Kilt.render "templates/main.slang"
end

# FIXME: Not sure how to handle this properly. This looks easy to break.
macro add_authd_cli_options(authd)
	Kemal.config.extra_options do |parser|
		parser.on "-k file", "--jwt-key file", "Provides the JWT key for authd." do |file|
			authd.key = File.read(file).chomp
		end
	end
end

class HTTP::Server::Context
	property authd_user : AuthD::User? = nil
end

class AuthD::Middleware < Kemal::Handler
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

class AuthD::Client
	def register_middleware
		add_handler AuthD::Middleware.new self
	end

	def export_registration_routes
		get "/register" do |env|
			if env.authd_user
				env.redirect "/"
				next
			end

			errors = Array(String).new

			main_template(env) {
				Kilt.render "templates/register.slang"
			}
		end

		post "/register" do |env|
			if env.authd_user
				env.redirect "/"
				next
			end

			login = get_safe_input env, "login"
			password  = get_safe_input env, "password"
			password2 = get_safe_input env, "password2"

			errors = Array(String).new

			# FIXME: Add some extra validation for logins.
			if login == ""
				errors << "Login is empty!"
			end

			if login.match /:/
				errors << "Login must not contain ':'."
			end

			if password != password2
				errors << "Entered passwords are different!"
			end

			if errors.size > 0
				next main_template(env) {
					Kilt.render "templates/register.slang"
				}
			end

			user = add_user login, password

			pp! user

			if user.is_a? Exception
				# AuthD::Client guarantees the message won’t be nil.
				# FIXME: Maybe this is not the right class, then.
				errors << user.message.not_nil!

				next main_template(env) {
					Kilt.render "templates/register.slang"
				}
			end

			token = get_token? login, password

			# Should not fail at this point.
			# FIXME: Maybe we need a AuthD::Client#add_user_with_token.
			if token
				env.session.string "token", token
			end

			# FIXME: Is that the right thing to do?
			env.redirect "/login"
		end
	end

	def export_login_logout_routes
		get "/login" do |env|
			user = env.authd_user
			login_error = nil

			main_template(env) { Kilt.render "templates/login.slang" }
		end

		get "/logout" do |env|
			env.session.destroy
			from = env.params.query["from"]?

			env.redirect from || "/"
		end

		post "/login" do |env|
			user = nil

			username = env.params.body["login"]?
			password = env.params.body["password"]?

			login_error = nil

			if username.nil?
				login_error = "“Login” field was left empty!"
			end
			if password.nil?
				login_error = "“Password” field was left empty!"
			end

			if login_error
				next main_template(env) { Kilt.render "templates/login.slang" }
			end

			# Should have next’d with a login error beforehand if those had been nil.
			username = username.not_nil!
			password = password.not_nil!

			token = get_token? username, password

			if token
				env.session.string "token", token
			else
				login_error = "Invalid credentials!"
				next main_template(env) { Kilt.render "templates/login.slang" }
			end

			from = env.params.query["from"]?
			env.redirect from || "/login"
		end
	end

	def export_profile_routes
		# FIXME: Are those the paths we want?
		get "/profile" do |env|
			user = env.authd_user

			unless user
				env.redirect "/login?from=#{env.request.path}"
				next
			end

			main_template(env) {
				Kilt.render "templates/profile.slang"
			}
		end

		post "/profile/password" do |env|
			user = env.authd_user

			unless user
				env.redirect "/login?from=#{env.request.path}"
				next
			end

			password_old = env.params.body["password_old"]
			password  = env.params.body["password"]
			password2 = env.params.body["password2"]

			if password != password2
				next # FIXME: boom
			end

			mod_user user.uid, password: password

			env.redirect "/profile"
		end

		# FIXME: User should be getting a new token after this.
		post "/profile/avatar" do |env|
			user = env.authd_user

			unless user
				env.redirect "/login?from=#{env.request.path}"
				next
			end

			avatar = env.params.body["avatar"]

			mod_user user.uid, avatar: avatar

			env.redirect "/profile"
		end
	end

	def export_all_routes
		export_login_logout_routes
		export_registration_routes
		export_profile_routes
	end
end

class AuthD::User
	def avatar
		avatar = previous_def

		if avatar.nil?
			digest = Digest::MD5.digest (other_contact || "#{login}@authd").downcase
			hash = digest.to_slice.hexstring
			avatar = "https://www.gravatar.com/avatar/#{hash}"
		end

		avatar
	end
end

