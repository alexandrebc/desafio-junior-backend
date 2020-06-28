# functions to handle auth by token in api
class Api::V1::ApiController < ActionController::Base
	before_action :require_login!
	helper_method :person_signed_in?, :current_user

	def user_signed_in?
		current_person.present?
  	end

	  def require_login!
  		return true if authenticate_token
  		render json: { data: 'Acesso negado' }, status: 401
  	end

  	def current_user
  		@_current_user ||= authenticate_token
  	end

  	private
  		def authenticate_token
  			User.find_by(token: request.headers['Authorization'])
  		end

end	