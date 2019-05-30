
- show_comments = attrs.fetch :comments, true
- short =         attrs.fetch :short, false
/ FIXME: Should have access to blog, which has access to authd. >_<
/        @blog.authd instead of using attrs.fetch and passing it around.
- authd =         attrs.fetch(:authd, nil)

- unless authd.is_a? AuthD::Client
	/ FIXME: See above FIXME. We shouldn’t have such exceptions.
	- raise Exception.new "Template could not access `authd`."

.section.blog-item
	.container
		article.card.article
			.card-content
				.media
					.media-content.has-text-centered
						a href=generate_url
							h2.title.is-1
								== @title_html

						- @authors.each do |id|
							- authd.get_user?(id).try do |author|
								.subtitle.is-6.author
									= author.full_name || author.login

				.content.article-body
					- if short && @body_markdown.size > 200
						== Markdown.to_html (@body_markdown[0..200] + "...")
					- else
						== @body_html

				- if show_comments
					- comments.not_nil!.to_h.to_a.map(&.[](1)).sort{|a, b| a.creation_date <=> b.creation_date}.each do |comment|
						== comment.to_html env, article: self, authd: authd

					form action=generate_url method="POST"
						textarea name="body" == env.session.string? "comment-body"
						input.button type="submit"

