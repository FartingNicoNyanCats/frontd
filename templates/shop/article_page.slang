.section
	.container
		.columns
			.column.is-one-quarter
				- image = @images[0]?
				- if image
					/ FIXME: Add JavaScript to change the displayed image when
					/        the buttons below are clicked.
					.section
						.figure.image
							img src=image

					.buttons.is-multiline
						- @images.each do |url|
							.button.image.is-64x64.is-clipped
								img.image.is-64x64 src=url
			.column

				.title.is-2 = @name
				- @description.try do |description|
					.content
						== Markdown.to_html description

				.columns
					.column
						= @price.to_s + " €"

					.column.is-narrow
						a.button.has-text-primary href="/shop/cart/add/#{HTML.escape @name}?from=#{env.request.resource}"
							/ FIXME: Replace by FontAwesome or something similar.
							.icon.has-text-bold == "🛒\u{FE0E} "
							| Add to cart


