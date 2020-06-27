module Api
	module V1
		class MessagesController < Api::V1::ApiController
			before_action :require_login!
			before_action :verify_author, only: [:show]

			# Show your messages, unless you'd "master" permission
			def index
				messages = current_user.master? ? Message.master_messages.ordered : Message.sent_to(current_user).ordered
				render json: { data: messages }, status: :ok
			end

			# Show message by id
			def show
				message = Message.find(params[:id])
				render json: { data: message }, status: :ok
			end

			# Create new message
			def create
				user = User.find_by_email(message_params[:receiver_email])
				message = Message.new(message_params.merge(from: current_user.id))
				message.to = user.id if user

				if message.save
					render json: { data: message }, status: :ok
				else
					render json: { data: 'Revise os dados' }, status: :unprocessable_entity
				end
			end

			# Sent messages by user
			def sent
				render json: {data: current_user.messages_sent}, status: :ok
			end

			private
				def message_params
					params.permit(
						:title,
						:content,
						:receiver_email,
						:to
					)
				end

				def verify_author
					message = Message.find(params[:id])
					render json: { data: 'Usuário não autorizado' }, status: :forbidden unless ([message.receiver, message.sender].include?(current_user) && !message.archived?) || current_user.master?
				end
		end
	end
end