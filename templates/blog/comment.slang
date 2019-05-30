- article = attrs.fetch(:article, nil).as Blog::Article
- authd = attrs.fetch(:authd, nil).as AuthD::Client

- if authd.nil?
	- raise Exception.new "`authd` client not provided to the Comment’s template."
- author = authd.get_user?(@author)

.media id="#{@id}"
	.media-left
		| FIXME:AUTHOR AVATAR (if any?)
	.media-content
		a href="##{@id}"
			.heading = author.try { |x| x.full_name || x.login }

			.content
				== @body_html
	.media-right
		= @creation_date
		- if article
			br!
			a href="/blog/#{article.title_markdown}/likes/#{@id}"
				= @likers.size
				| 👍

