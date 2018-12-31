
# FIXME: Namespace? What would be a good namespace for this? FrontD?
# FIXME: Define somewhere else?
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

# FIXME: This is the most critical part to deduplicate.
def main_template(env, **attrs, &block)
	user = env.authd_user

	page_title = attrs.fetch :title, nil

	Kilt.render "templates/main.slang"
end

class Blog::Article
	# FIXME: The /blog part should be somewhat configurable. Articles need
	#        a reference to their Blog instance!
	def generate_url
		"/blog/#{HTML.escape @title_markdown}"
	end
end

class Blog
	def export_index
		get "/blog" do |env|
			current_article = nil

			main_template(env) {
				Kilt.render "templates/blog.slang"
			}
		end
	end

	def export_articles_pages
		get "/blog/:title" do |env|
			title = HTML.unescape env.params.url["title"]

			# Note: should match Blog::Article#generate_url.
			current_article = articles.find &.title_markdown.==(title)

			if current_article.nil?
				next halt env, status_code: 404
			end

			main_template(env) {
				Kilt.render "templates/blog.slang"
			}
		end
	end

	def export_articles_input_pages
		get "/blog/new-article" do |env|
			main_template(env) {
				Kilt.render "templates/blog/new-article.slang"
			}
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

			self << article

			env.redirect from || "/blog"
		end
	end

	def export_all_routes
		export_articles_pages
		export_index
		export_articles_input_pages
	end
end

