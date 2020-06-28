module Api
	module V1
		class ProfilesController < Api::V1::ApiController
			before_action :require_login!

			# show actual profile
			def show
				render json: { data: current_user }, status: :ok
			end  

			# update user info
			def update
				# dont update password if both fields are not filled
				user_update = user_params
				if user_params[:password].blank? || user_params[:password_confirmation].blank? || user_params[:password] != user_params[:password_confirmation]
					if user_params[:password] != user_params[:password_confirmation]
						pwdFlag = true
					end

					user_update = user_params.except(:password, :password_confirmation)
				end

				if pwdFlag
					render json: { data: 'Revise se a senha foi corretamente digitada duas vezes.'}, status: :unprocessable_entity
				elsif current_user.update(user_update)
					render json: { data: 'Perfil editado com sucesso.' }, status: :ok
				else
					render json: { data: message.errors }, status: :unprocessable_entity
				end
			end

			private
				def user_params
					params.require(:user).permit(
						:name,
						:email,
						:password,
						:password_confirmation
					)
				end
		end
	end
end