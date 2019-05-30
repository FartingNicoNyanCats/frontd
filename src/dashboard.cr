
class FrontD::Dashboard
	class Page
		getter link : String
		getter title : String
		@authorized : Proc(AuthD::User, Bool)

		def initialize(@link, @title)
			@authorized = Proc(AuthD::User, Bool).new { true }
		end

		def initialize(@link, @title, &block : Proc(AuthD::User, Bool))
			@authorized = block
		end

		def authorized?(user : AuthD::User)
			@authorized.call user
		end
	end

	def initialize()
		@pages = Array(Page).new

		@pages << Page.new "", "Dashboard"
	end

	def render(env, **attrs, &block)
		user = env.authd_user

		# FIXME: Being logged in should not be enough.
		if user.nil?
			env.response.status_code = 403
			raise FrontD::AuthenticationError.new "You need to be logged in to access the dashboard!"
		end

		main_template(env) {
			Kilt.render "templates/dashboard.slang"
		}
	end

	def export_all_routes
		get "/dashboard" do |env|
			render(env) {}
		end
	end

	def register(thing)
		@pages << thing.dashboard_page
	end
end

