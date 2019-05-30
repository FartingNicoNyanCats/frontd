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
	getter articles_storage
	getter authd : AuthD::Client

	def initialize(@authd, @data_directory = "storage")
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
			load_comments article

			articles << article
		end
		articles
	end

	def <<(article : Article)
		article.id ||= UUID.random

		@articles_storage[article.id.not_nil!] = article
	end

	private def load_comments(article)
		article.comments = FS::Hash(String, Comment).new comments_directory(article)
	end
end

class Blog::Article
	class JSON
		::JSON.mapping({
			authors: Array(Int32),
			body_markdown: String,
			body_html: String?,
			title_markdown: String,
			title_html: String?,
			tags: Array(String),
			creation_date: {
				type: Time,
				default: Time.now
			},
			id: UUID?
		})

		def initialize(article : Article)
			@authors = article.authors
			@body_markdown = article.body_markdown
			@body_html = article.body_html
			@title_markdown = article.title_markdown
			@title_html = article.title_html
			@tags = article.tags
			@id = article.id
			@creation_date = Time.now
		end
	end

	property id           : UUID? = nil
	getter authors        = Array(Int32).new
	getter body_markdown  : String
	getter body_html      : String?
	getter title_markdown : String
	getter title_html     : String?
	getter creation_date  : Time
	getter tags           = Array(String).new

	# Bleh. I really don’t like the idea of it being nillable.
	property comments : FS::Hash(String, Comment)?

	def initialize(article : Article::JSON)
		@authors = article.authors
		@body_markdown = article.body_markdown
		@title_markdown = article.title_markdown

		@body_html = Markdown.to_html @body_markdown
		@title_html = Markdown.to_html @title_markdown

		@tags = article.tags

		@creation_date = article.creation_date

		@id = article.id
	end

	def initialize(title : String = "", author : Int32? = nil, body : String = "")
		@body_markdown = body
		@title_markdown = title

		@body_html = Markdown.to_html @body_markdown
		@title_html = Markdown.to_html @title_markdown

		@creation_date = Time.now

		if author
			@authors << author
		end
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

	def to_html(env, **attrs)
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
	::JSON.mapping({
		id: String,
		author: Int32,
		creation_date: Time,
		body_markdown: String,
		body_html: String?,
		likers: Array(Int32)
	})

	def initialize(@author : Int32, @body_markdown : String)
		@id = UUID.random.to_s
		@body_html = Markdown.to_html @body_markdown
		@creation_date = Time.now
		@likers = Array(Int32).new
	end

	def like(user : AuthD::User)
		unless @likers.any? &.==(user.uid)
			@likers << user.uid
		else
			@likers.reject! &.==(user.uid)
		end
	end
end

require "./blog/kemal.cr"

