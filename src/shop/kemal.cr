
def main_template(env, **attrs, &block)
	user = env.authd_user

	page_title = attrs.fetch :title, nil

	Kilt.render "templates/main.slang"
end

class HTTP::Server::Context
	property shop_cart : Shop::Cart? = nil
end

class Shop::Middleware < Kemal::Handler
	def call(context)
		cart_string = context.session.string? "cart"

		if cart_string.nil?
			return call_next context
		end

		begin
			cart = Shop::Cart.from_json cart_string
		rescue
			return call_next context
		end

		context.shop_cart = cart

		call_next context
	end
end

class Shop
	def register_middleware
		add_handler Shop::Middleware.new
	end

	def export_all_routes
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
			article = articles.find &.name.==(article_name)

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
			article = articles.find &.name.==(article_name)

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
				Kilt.render "templates/shop/cart.slang"
			}
		end
	end
end

