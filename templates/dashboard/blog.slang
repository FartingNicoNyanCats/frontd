
.section
	.container
		form action="/blog/articles?from=#{env.request.resource}" method="post"
			label.label Title
			input.input type="text" name="title"

			/ disabled was coming soon to Bulma at the time of writing.
			fieldset disabled=
				label.label Author
				input.input type="text" placeholder=(env.authd_user.try { |u| u.full_name || u.login })

			label.label Text
			textarea.input name="body"

			input.button type="submit" value="Send!"

