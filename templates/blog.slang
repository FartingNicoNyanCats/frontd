
/ FIXME: Display only the last X articles.
- if current_article
	== current_article.to_html env, authd: @authd
- else
	- each_article do |article|
		== article.to_html env, authd: @authd, comments: false, short: true

