
.section
	.container
		- login_error.try do
			== login_error
				
		- if user
			p Welcome, #{user.login}!

			p Your cart is currently empty, because carts have not been implemented!

			p You’ll also probably want to do account management operations at some point (like setting your username, changing your avatar picture, and so on). All of that is also unimplemented at the moment. But fear not, for the day those features be in production is coming!

		- else
			form method="POST" action="/login"
				.field
					label.label Login
					input.input name="login"

				.field
					label.label Password
					input.input type="password" name="password"

				.control
					input.button type="submit" value="Log in"

