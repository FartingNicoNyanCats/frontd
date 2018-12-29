
- user = env.authd_user

.card
	.card-content
		.media
			.media-left
				figure.image.is-48x48
					- image = @images[0]?
					- if image.nil?
						img src="https://bulma.io/images/placeholders/96x96.png"
					- else
						img src=image
			.media-content
				.title.is-3 = @name

				- @description.try do |description|
					.content
						== Markdown.to_html description

			.media-right
				= "#{article_quantity} items"
				br
				= @price.to_s + " €"

	.card-footer
		a.card-footer-item href="/shop/articles/#{HTML.escape @name}"
			| View
		a.card-footer-item.has-text-warning href=""
			| Add one
		a.card-footer-item.has-text-warning href=""
			| Remove one
		a.card-footer-item.has-text-warning href=""
			| Remove all


