.section
	.container
		- if errors
			- errors.each do |error|
				.message.is-danger
					.message-body
						= error
		form method="POST" action="/register"
			.field
				label.label Login
				input.input name="login"

			.field
				label.label Password
				input.input type="password" name="password"

			.field
				label.label Password (repeat)
				input.input type="password" name="password2"

			.control
				input.button type="submit" value="Register!"

