
.columns
	.column.is-one-quarter
		.menu
			/ FIXME: That list NEEDS to be dynamic and items’ permissions checked.
			ul.menu-list
				- user = env.authd_user
				- @pages.each do |page|
					- if page.authorized? user.not_nil!
						li
							a href="/dashboard#{page.link}" = page.title

	.column
		== yield

