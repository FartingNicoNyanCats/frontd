require "kemal"
require "kilt/slang"

class Shop
	property articles

	def initialize
		@articles = Array(Article).new
	end

	class Article
		JSON.mapping({
			name:   String,
			price:  Float64, # FIXME: Is that safe?
			description: String?, # FIXME: XSS protection? Markdown input?
			images: {
				type: Array(String), # Contains URL.
				default: Array(String).new
			},
			category: String?
		})

		def to_html_card(env)
			Kilt.render "templates/article.slang"
		end

		def to_html_page(env)
			Kilt.render "templates/shop/article_page.slang"
		end

		def to_html_cart(env, article_quantity)
			Kilt.render "templates/shop/article_cart.slang"
		end
	end

	class Cart
		getter articles = Hash(String, Int32).new

		JSON.mapping({
			articles: Hash(String, Int32)
		})

		def initialize
		end

		def <<(article)
			@articles[article.name] = (@articles[article.name]? || 0) + 1
		end
	end

	def register_article(article : Article)
		@articles << article
	end

	def get_article(name : String) : Article | Nil
		@articles.find &.name.==(name)
	end
end

macro add_shop_middleware
	class HTTP::Server::Context
		property shop_cart : Shop::Cart? = nil
	end

	class ShopMiddleware < Kemal::Handler
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

	add_handler ShopMiddleware.new
end

