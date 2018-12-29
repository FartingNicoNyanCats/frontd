require "uuid"
require "markdown"

require "kilt/slang"

require "fs"

struct UUID
	def to_json(builder)
		to_s.to_json builder
	end

	def self.new(pp : JSON::PullParser)
		::UUID.new String.new pp
	end
end

class Blog
	def initialize(@data_directory = "storage")
		@articles_directory = "#{@data_directory}/articles"

		@articles_storage = FS::Hash(UUID, Article).new @data_directory
	end

	def comments_directory(article : Blog::Article)
		"#{@data_directory}/comments/#{article.id}"
	end

	def each_article(&block)
		@articles_storage.each do |key, article|
			next if article.nil?

			# FIXME: Should be automated in FS.
			article.id = UUID.new key

			yield article
		end
	end

	def articles
		articles = Array(Article).new
		each_article do |article|
			articles << article
		end
		articles
	end

	def <<(article : Article)
		article.id ||= UUID.random

		@articles_storage[article.id.not_nil!] = article
	end
end

class Blog::Article
	class JSON
		::JSON.mapping({
			author: String,
			body_markdown: String,
			body_html: String?,
			title_markdown: String,
			title_html: String?,
			id: UUID?
		})

		def initialize(article : Article)
			@author = article.author
			@body_markdown = article.body_markdown
			@body_html = article.body_html
			@title_markdown = article.title_markdown
			@title_html = article.title_html
			@id = article.id
		end
	end

	property id : UUID? = nil
	getter author : String
	getter body_markdown : String
	getter body_html : String?
	getter title_markdown : String
	getter title_html : String?

	def initialize(article : Article::JSON)
		@author = article.author
		@body_markdown = article.body_markdown
		@title_markdown = article.title_markdown

		@body_html = Markdown.to_html @body_markdown
		@title_html = Markdown.to_html @title_markdown

		@id = article.id
	end

	# FIXME: Should all of those really have default arguments?
	def initialize(title : String = "", @author : String = "", body : String = "")
		@body_markdown = body
		@title_markdown = title

		@body_html = Markdown.to_html @body_markdown
		@title_html = Markdown.to_html @title_markdown
	end

	def self.from_json(string) : Article?
		begin
			json = JSON.from_json string
		end

		return nil if json.nil?

		Article.new json
	end

	def to_json : String
		::Blog::Article::JSON.new(self).to_json
	end

	def to_html
		Kilt.render "templates/blog/article.slang"
	end

	def to_html_list_item
		HTML.build {
			li class: "title is-1" {
				a href: "/blog/" + @title {
					text @title
				}
			}
		}
	end
end

class Blog::Comment
	class JSON
		::JSON.mapping({
			author: String,
			body_markdown: String,
			body_html: String?
		})
	end
end

blog = Blog.new

blog.each_article do |article|
	p article
end

