
.hero.is-info.is-bold.blog-picture
	.hero-body
		/ Currently empty. Article picture will
		/ be here in the future.

.section.blog-item
	.container
		article.card.article
			.card-content
				.media
					.media-content.has-text-centered
						a href="/blog/#{HTML.escape @title_markdown}"
							h2.title.is-1
								== @title_html

						- @author.try do |author|
							.subtitle.is-6.author
								= author

				.content.article-body
					== @body_html

