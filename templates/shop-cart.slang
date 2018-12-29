
.section
	.container
		- cart = env.shop_cart
		- if cart
			.columns
				.column.is-half
					/ Stores article as HTML widgets, or nil if error.
					- articles = cart.articles.map do |name, amount|
						- article = shop.get_article(name)
						- if article
							- article.to_html_cart env, amount

					- if articles.includes? nil
						.message.is-danger
							.content
								p A fatal error occured with your cart!
								p Please the service’s technical team and report as many informations about your situation as you can!
					- else
						- articles.each do |html|
							== html.not_nil!
					br
				.column
					| Total: 
					/ FIXME: This should be a property of shop or of cart or something.
					- total = cart.articles.reduce 0 do |acc, tuple|
						- next if acc.nil? # Cart contains invalid articles.
						- name, amount = tuple
						- article = shop.get_article name
						- next if article.nil?
						- acc + article.price * amount
					= total
		- else
			.content
				h3 Your cart is empty!
				p This page displays the content of your cart, but your cart is empty.
				p Nothing to do, here! You probably want to go back to the shop.

