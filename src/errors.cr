
# FIXME: Define somewhere else?
class FrontD::InvalidInput < Kemal::Exceptions::CustomException
	def initialize(@message)
	end
end

class FrontD::AuthenticationError < Kemal::Exceptions::CustomException
	def initialize(@message)
	end
end

# FIXME: Namespace? Naming? Is behavior alright?
# FIXME: Other status codes, error messages or data transformations?
def get_safe_input(env : HTTP::Server::Context, key : String) : String
	begin
		env.params.body[key]
	rescue
		env.response.status_code = 403
		raise FrontD::InvalidInput.new "Field '#{key}' was not provided"
	end
end


