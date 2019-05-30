
/ Duplicating `articles` so that it can be transformed later down the line.
- articles = self.articles
- category = env.params.url["category_name"]?

nav.navbar.is-light
	.container
		.navbar-menu
			.navbar-start
				a.navbar-item href="/shop"
					| (all items)
				- articles.map(&.category).uniq.compact.each do |category|
					a.navbar-item href="/shop/categories/#{category}"
						= category

- if category
	- articles = articles.select &.category.==(category)

- page = env.params.query["page"]?.try(&.to_i) || 0

- articles_per_page = 15

- page_articles = get_page_things env, articles, page, articles_per_page

.section
	.container
		.columns
			.column.is-one-third
				- page_articles.each_with_index do |article, i|
					- next if article.nil?
					- if i % 3 == 0
						br
						== article.to_html_card env
			.column.is-one-third
				- page_articles.each_with_index do |article, i|
					- next if article.nil?
					- if i % 3 == 1
						br
						== article.to_html_card env
			.column.is-one-third
				- page_articles.each_with_index do |article, i|
					- next if article.nil?
					- if i % 3 == 2
						br
						== article.to_html_card env

		== pagination_list env, articles, page, articles_per_page

