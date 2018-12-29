
- articles = shop.articles
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

- page = env.params.query["page"]?
- if page.nil?
	- page = 0
- else
	- page = page.to_i

- articles_per_page = 15

- page_articles = articles.in_groups_of(articles_per_page)[page]?
- if page_articles.nil?
	- page_articles = articles.in_groups_of(articles_per_page)[0]

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

		nav.pagination
			- last_page = articles.size / articles_per_page
			- if page > 0
				a.pagination-previous href="#{env.request.path}?page=#{page-1}"
					| Previous Page
			- if page < last_page - 1
				a.pagination-next href="#{env.request.path}?page=#{page+1}"
					| Next Page

			ul.pagination-list
				- current_page = page
				- (page-2..page+2).each do |page|
					- if page >= 0 && page < articles.size/articles_per_page
						- if page == current_page - 2
							- if page != 0
								li
									a.pagination-link href="#{env.request.path}?page=0"
										= 0
								li
									.pagination-ellipsis …

						li
							- if page == current_page
								a.pagination-link.is-current href="#{env.request.path}?page=#{page}"
									= page
							- else
								a.pagination-link href="#{env.request.path}?page=#{page}"
									= page

						- if page == current_page + 2
							- if page != last_page
								li
									.pagination-ellipsis …
								li
									a.pagination-link href="#{env.request.path}?page=#{last_page}"
										= last_page

