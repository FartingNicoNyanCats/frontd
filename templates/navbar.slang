nav.navbar
	.container
		.navbar-brand
			a.navbar-item href="/"
				.title.is-5 Mii-chan Online
		.navbar-menu.is-active
			.navbar-start
				/ FIXME: Those should probably be somewhat more automated. plz
				a.navbar-item href="/shop"
					| Shop
				a.navbar-item href="/blog"
					| Blog
				- if env.shop_cart
					a.navbar-item href="/shop/cart"
						| Cart

		.navbar-end
			- if user
				a.navbar-item href="/login"
					.image.is-24x24.avatar
						img.is-rounded src="https://bulma.io/images/placeholders/24x24.png" alt="User Avatar"
					| #{user.full_name || user.login}

				a.navbar-item href="/logout"
					| Logout
			- else
				a.navbar-item href="/register" Sign in
				a.navbar-item href="/login" Login
			
