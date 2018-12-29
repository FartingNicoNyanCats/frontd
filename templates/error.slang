
.hero.is-danger.is-bold
	.hero-body
		.container
			.title.is-1 Oh no, you have found a bad, bad error!
			.subtitle.is-2 It’s a #{env.response.status_code} error.

			- message = exception.message
			.content
				p
					= message

.hero
	.hero-body
		.container
			.section
				.content
					p Not much you can do about it now. Maybe try to go back?

					/ FIXME: Admin contact.
					p If you need help, you could always contact the admin!

		.container
			.section
				a.button.is-medium.is-primary href="/shop" Shop
				a.button.is-medium href="/shop/cart" Cart
				- if env.authd_user.nil?
					a.button.is-medium href="/login" Log in
				- else
					a.button.is-medium href="/login" Account
				a.button.is-medium href="/" Home


