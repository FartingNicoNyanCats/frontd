
require "kemal"
require "kemal-session"
require "kilt/slang"
require "markdown"

require "ipc"

require "./authd.cr"
require "./shop.cr"
require "./builder.cr"
require "./blog.cr"

require "authd"

Kemal::Session.config.secret = "I wanted to mule but I’m all out of Reppuu."

authd = AuthD::Client.new

add_authd_cli_options authd
add_authd_middleware authd

shop = Shop.new

add_shop_middleware

blog = Blog.new

# FIXME: Test data here.

pp! shop.register_article Shop::Article.from_json %<{
	"name":  "夕立",
	"price": 666.66,
	"description": "Uncontested best grill. Will wreck your enemies during both day and night battle.",
	"category": "shiratsuyu",
	"images": [
		"https://cdn41.picsart.com/170296069000202.jpeg?c256x256",
		"https://vignette.wikia.nocookie.net/kancolle/images/a/ae/Yuudachi_Kai_Ni_New_Year%27s_Full.png/revision/latest/scale-to-width-down/300?cb=20141231190132",
		"https://vignette.wikia.nocookie.net/kancolle/images/b/bc/Yuudachi_Kai_Ni_Full.png/revision/latest/scale-to-width-down/300?cb=20181029142944"
	]
}>

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Shiratsuyu",
	"price": 666.66,
	"description": "Is the first ship of her class. Yes, the *first* ship!",
	"category": "shiratsuyu",
	"images": [
		"https://vignette.wikia.nocookie.net/kancolle/images/c/c8/F283173ff237e809bb3b7db29846b15562c21632v2_hq.jpg/revision/latest?cb=20180713214052"
	]
}}

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Shigure",
	"price": 666.66,
	"category": "shiratsuyu",
	"description": "Likes the rain and dislikes night battles.\\n\\n…\\n\\nYes, I know, a destroyer who dislikes night battles… it makes no sense, right?"
}}

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Murasame",
	"category": "shiratsuyu",
	"price": 666.66
}}

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Harusame",
	"price": 666.66,
	"category": "shiratsuyu",
	"description": "The cutest of them all. Has never seen much combat, however. Good for carrying supplies around though."
}}

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Kawakaze",
	"price": 666.66,
	"category": "shiratsuyu",
	"description": "Looks crazy. Sounds crazy. Probably *is* crazy."
}}

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Umikaze",
	"category": "shiratsuyu",
	"price": 666.66
}}

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Yamakaze",
	"price": 666.66,
	"category": "shiratsuyu",
	"description": "Mountain wind? Weird name for a weird ship daze~"
}}

pp! shop.register_article Shop::Article.from_json %{{
	"name":  "Shimakaze",
	"price": 9812.13,
	"description": "Is fast and has cute 12.7cm turret-chans."
}}

50.times do |i|
	pp! shop.register_article Shop::Article.from_json %{{
		"name":  "Random<#{i}>",
		"price": 9812.13,
		"description": "The article n°#{i} in the list of 50 random articles.",
		"category": "Random"
	}}
end

puts "WARNING: Adding lots of new, random articles for testing purposes"
10000.times do |i|
	n = Random.rand 5

	shop.register_article Shop::Article.from_json %{{
		"name":  "Random<#{n},#{i}>",
		"price": 9812.13,
		"description": "The article n°#{i} in the list of 10 000 random articles.",
		"category": "Random #{n}"
	}}
end

def main_template(env, **attrs, &block)
	user = env.authd_user

	page_title = attrs.fetch :title, nil

	page_title = if page_title
		"みい-ちゃん - #{page_title}"
	else
		page_title = "みい-ちゃん"
	end

	Kilt.render "templates/main.slang"
end

get "/" do |env|
	main_template(env) {
		Kilt.render "templates/index.slang"
	}
end

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

	user = authd.add_user login, password

	pp! user

	if user.is_a? Exception
		# AuthD::Client guarantees the message won’t be nil.
		# FIXME: Maybe this is not the right class, then.
		errors << user.message.not_nil!

		next main_template(env) {
			Kilt.render "templates/register.slang"
		}
	end

	token = authd.get_token? login, password

	# Should not fail at this point.
	# FIXME: Maybe we need a AuthD::Client#add_user_with_token.
	if token
		env.session.string "token", token
	end

	# FIXME: Is that the right thing to do?
	env.redirect "/login"
end

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

	token = authd.get_token? username, password

	if token
		env.session.string "token", token
	else
		login_error = "Invalid credentials!"
		next main_template(env) { Kilt.render "templates/login.slang" }
	end

	from = env.params.query["from"]?
	env.redirect from || "/login"
end

# FIXME: Should non-general (shop, blog, forum, and so on) routes be exported from a class or module instance?
get "/shop" do |env|
	main_template(env) {
		Kilt.render "templates/shop.slang"
	}
end

get "/shop/categories/:category_name" do |env|
	main_template(env) {
		Kilt.render "templates/shop.slang"
	}
end

get "/shop/articles/:article-name" do |env|
	article_name = env.params.url["article-name"]
	article = shop.articles.find &.name.==(article_name)

	unless article
		next halt env, status_code: 404
	end

	main_template(env) {
		article.to_html_page env
	}
end

get "/shop/cart/add/:article-name" do |env|
	# FIXME: Redirect back to wherever the user came from!!

	article_name = env.params.url["article-name"]
	article = shop.articles.find &.name.==(article_name)

	if article.nil?
		# FIXME: Should this really be ignored?
		from = env.params.query["from"]?
		env.redirect from || "/shop"
		next
	end

	cart = env.shop_cart

	if cart.nil?
		cart = Shop::Cart.new
	end
	puts "OH NO, SHOULD BE ADDING #{article.name} TO CART"

	cart << article

	env.session.string "cart", cart.to_json

	from = env.params.query["from"]?
	env.redirect from || "/shop"
end

get "/shop/cart" do |env|
	main_template(env) {
		Kilt.render "templates/shop-cart.slang"
	}
end

get "/blog" do |env|
	current_article = nil

	main_template(env) {
		Kilt.render "templates/blog.slang"
	}
end

get "/blog/:title" do |env|
	title = HTML.unescape env.params.url["title"]

	current_article = blog.articles.find &.title_markdown.==(title)

	if current_article.nil?
		next halt env, status_code: 404
	end

	main_template(env) {
		Kilt.render "templates/blog.slang"
	}
end

get "/blog/new-article" do |env|
	main_template(env) {
		Kilt.render "templates/blog/new-article.slang"
	}
end

# FIXME: Namespace? What would be a good namespace for this? FrontD?
class InvalidInput < Kemal::Exceptions::CustomException
	def initialize(@message)
	end
end

# FIXME: Namespace? Naming? Is behavior alright?
# FIXME: Other status codes, error messages or data transformations?
def get_safe_input(env : HTTP::Server::Context, key : String) : String
	begin
		env.params.body[key]
	rescue
		env.response.status_code = 403
		raise InvalidInput.new "Field '#{key}' was not provided"
	end
end

post "/blog/articles" do |env|
	from = env.params.query["from"]?

	# FIXME: Client-side will also need JS integration to show missing/empty fields and such.

	title = get_safe_input env, "title"
	body = get_safe_input env, "body"

	begin
		# FIXME: second .not_nil! is a design flaw from AuthD.
		author = env.authd_user.not_nil!.login.not_nil!
	rescue
		env.response.status_code = 403
		# FIXME: Maybe… another exception?
		raise InvalidInput.new "You must be logged in!"
	end

	article = Blog::Article.new title: title, author: author, body: body

	blog << article

	env.redirect from || "/blog"
end

{400, 403, 404, 500}.each do |status_code|
	error status_code do |env, exception|
		env.response.status_code = status_code

		main_template(env) {
			Kilt.render "templates/error.slang"
		}
	end
end

Kemal.run

