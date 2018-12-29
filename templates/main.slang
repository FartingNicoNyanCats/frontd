doctype html
html
	head
		meta charset="utf-8"
		title
			== page_title

		/ CSS should probably be removed once SASS
		/ is made part of the toolchain.
		link href="/style.css" rel="stylesheet"
		css:
			| .navbar .avatar {
			| 	margin-right: 8px;
			| }

	body
		== Kilt.render "templates/navbar.slang"

		== yield

		== Kilt.render "templates/footer.slang"
