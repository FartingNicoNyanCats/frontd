
.section
	.container
		form action="/blog/articles?from=#{env.request.resource}" method="post"
			label.label Title
			input.input type="text" name="title"

			label.label Author
			/ FIXME: Lock it. It’s informative only ATM.
			input.input type="text"
				= env.authd_user.try &.login

			label.label Text
			textarea.input name="body"

			input.button type="submit" value="Send!"

