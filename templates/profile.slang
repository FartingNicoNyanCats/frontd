
/ FIXME: Just make it an error page or a redirect if there’s no user.
- user = env.authd_user.not_nil!

.section
	.container
		.message.is-danger
			.message-body
				.content
					h2 WARNING

					p This form is still non-functionnal and unimplemented server-side!
		.box
			.columns
				.column.is-narrow
					- avatar = user.avatar || "https://bulma.io/images/placeholders/128x128.png"
					img src=avatar alt="user avatar"
				.column
					form.form action="/profile/avatar" method="post"
						.field
							label.label Current avatar URL
							.control
								input.input disabled="true" placeholder=user.avatar

						/ WTF Bulma?
						.field
							label.label New avatar URL
						.field.has-addons
							.control
								input.input type="text" name="avatar" value=
							.control
								button.button.is-success type="submit" Update!

		.form action="/profile/basics" method="post"
			.box
				.field.is-horizontal
					.field-label
						label.label Full Name
					.field-body
						.control
							input.input type="text" name="full_name" value=user.full_name

				.field.is-horizontal
					.field-label
						label.label E-Mail Address
					.field-body
						.control
							input.input type="text" name="email" value=user.other_contact
				.field.is-horizontal
					.field-label
					.field-body
						.control
							input.button.is-success type="submit" value="Update!"

		form.form action="/profile/password" method="post"
			.box
				.field.is-horizontal
					.field-label
						label.label Password

					.field-body
						.control
							label.label Password (current)
							input.input type="password" name="password_old"
							label.label Password
							input.input type="password" name="password"
							label.label Password (repeat)
							input.input type="password" name="password2"

				.field.is-horizontal
					.field-label
					.field-body
						.control
							button.button.is-success type="submit" Update!

