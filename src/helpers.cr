
def get_page_things(env, things, current_page, things_per_page)
	things[things_per_page * current_page .. things_per_page * (current_page+1)]
end

def pagination_list(env, things, current_page, things_per_page)
	Kilt.render "templates/helpers/pagination.slang"
end

