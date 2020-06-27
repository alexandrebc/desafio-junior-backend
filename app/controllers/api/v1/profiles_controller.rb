module Api
	module V1
		class ProfilesController < ApplicationController
			before_action :authenticate
			skip_before_action :verify_authenticity_token

			# Listar todos as mensagens
			def show
				render json: { data: @user }, status: :ok
			end  

			# update user info
			def update
				# puts 'oi'
				if user_params[:password].blank? || user_params[:password_confirmation].blank? # remove password if both fields are not filled
					user_params.delete(:password)
					user_params.delete(:password_confirmation)
				end

				if @user.update(user_params)
					bypass_sign_in(@user) # if user change password sign_in user again
					render json: { data: 'Perfil editado com sucesso.' }, status: :ok
				else
					render json: { data: message.errors }, status: :unprocessable_entity
				end
			end

			private
				# Verificação do token Header -> DB
				def authenticate
					authenticate_with_http_token do |token, options|
						@user = User.find_by(token: token)
					end
				end

				def user_params
					params.permit(
						:name,
						:email,
						:password,
						:password_confirmation
					)
				end
		end
	end
end