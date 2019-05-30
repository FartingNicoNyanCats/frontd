
require "kemal"
require "kemal-session"
require "kemal-watcher"
require "kilt/slang"
require "markdown"

require "ipc"

require "./authd.cr"
require "./dashboard.cr"
require "./shop.cr"
require "./builder.cr"
require "./blog.cr"
require "./helpers.cr"

require "authd"

include FrontD

Kemal::Session.config.secret = "I wanted to mule but I’m all out of Reppuu."

authd = AuthD::Client.new

authd.register_middleware
authd.export_all_routes

add_authd_cli_options authd

dashboard = Dashboard.new

shop = Shop.new

shop.register_middleware
shop.export_all_routes

blog = Blog.new authd

blog.export_all_routes dashboard

dashboard.register blog

# Must be called after everything else has been defined.
dashboard.export_all_routes

# FIXME: Test data here.
require "./test_data.cr"

shop.register_test_data

def main_template(env, **attrs, &block)
	user = env.authd_user

	page_title = attrs.fetch :title, nil

	Kilt.render "templates/main.slang"
end

get "/" do |env|
	main_template(env) {
		Kilt.render "templates/index.slang"
	}
end

{400, 403, 404, 500}.each do |status_code|
	error status_code do |env, exception|
		env.response.status_code = status_code

		main_template(env) {
			Kilt.render "templates/error.slang"
		}
	end
end

{% if flag?(:dev) %}
	module Kemal
		def self.watch(files)
			websocket_server
			watcher files
		end
	end

	get "/watcher.js" do |env|
		env.response.content_type = "application/javascript"
		# Terrible. But putting it in public/ would mean the raw version is extracted.
		File.read("./watcher.js").sub /@WEBSOCKETPATH/, Kemal::WEBSOCKETPATH
	end

	Kemal.watch [
		"public/*.css",
		"public/*.js"
	]
{% end %}

Kemal.run

