module Api
	module V1
		class MessagesController < ApplicationController

			# Listar todos as mensagens
			def index
				render json: {status: 'SUCCESS', message: 'Olá'}, status: :ok
			end

		end
	end
end