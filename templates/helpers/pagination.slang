
- page = current_page

nav.pagination
	- last_page = (things.size / things_per_page).ceil
	- pp last_page
	- if page > 0
		a.pagination-previous href="#{env.request.path}?page=#{page-1}"
			| Previous Page
	- if page < last_page
		a.pagination-next href="#{env.request.path}?page=#{page+1}"
			| Next Page

	ul.pagination-list
		- (page-2..page+2).each do |page|
			- if page >= 0 && page <= last_page
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

