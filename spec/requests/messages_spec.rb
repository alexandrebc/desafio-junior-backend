require 'rails_helper'

RSpec.describe Api::V1::MessagesController do
	let(:user) { FactoryBot.create(:user) }
	let(:user1) { FactoryBot.create(:user) }
	let(:user2) { FactoryBot.create(:user) }
	let(:master) { FactoryBot.create(:user, :master) }
	let!(:message) { FactoryBot.create(:message, to: user.id, from: user1.id) }
	let!(:message1) { FactoryBot.create(:message, to: user.id, from: user1.id) }
	let!(:message2) { FactoryBot.create(:message, to: user1.id, from: user.id) }
	let!(:message3) { FactoryBot.create(:message, to: user2.id, from: user1.id) }
	let(:header) do
		{ 'Authorization': user.token }
	end
	let(:headerMaster) do
		{ 'Authorization': master.token }
	end

	describe 'with normal token' do
		describe 'GET /api/v1/messages'  do
			subject(:index_messages) do
				get '/api/v1/messages', headers: header
			end

			it 'returns two messages' do
				index_messages
				json_response = JSON.parse(response.body)
				expect(json_response['data'].size).to eq 2
			end
			
			it 'return 200' do
				index_messages
				expect(response.status).to eq 200
			end  
		end

		describe 'GET /api/v1/messages/:id'  do
			subject(:show_messages) do
				get '/api/v1/messages/' + message.id.to_s, headers: header
			end

			it 'return message with id equal at URI' do
				show_messages
				json_response = JSON.parse(response.body)
				expect(json_response['data']['id']).to eq message.id
			end
			
			it 'return 200' do
				show_messages
				expect(response.status).to eq 200
			end  
		end

		describe 'GET /api/v1/messages/:id'  do
			subject(:show_messages) do
				get '/api/v1/messages/' + message3.id.to_s, headers: header
			end

			it 'cant see a message that isnt for/from user' do
				show_messages
				json_response = JSON.parse(response.body)
				expect(json_response['data']).to eq('Usuário não autorizado')
			end
			
			it 'return 403' do
				show_messages
				expect(response.status).to eq 403
			end  
		end

		describe 'GET /api/v1/messages/sent' do
			subject(:sent_messages) do
				get '/api/v1/messages/sent', headers: header
			end

			it 'return one message sent' do
				sent_messages
				json_response = JSON.parse(response.body)
				expect(json_response['data'].size).to eq 1
			end
			
			it 'return 200' do
				sent_messages
				expect(response.status).to eq 200
			end  
		end

		describe 'POST /api/v1/messages' do
			let(:newMessage) do
				{ 
					'title': 'titulo', 
					'content': 'conteudo', 
					'receiver_email': user1.email
				}
			end

			subject(:create_message) do
				post '/api/v1/messages', params: { 'message': newMessage }, headers: header
			end

			it 'return the created message' do
				create_message
				json_response = JSON.parse(response.body)
				expect(json_response['data']['title']).to eq newMessage.fetch(:title)
			end
			
			it 'return 200' do
				create_message
				expect(response.status).to eq 200
			end  
		end

		describe 'POST /api/v1/messages' do
			let(:newMessage) do
				{ 
					'title': 'titulo', 
					'receiver_email': user1.email
				}
			end

			subject(:create_message) do
				post '/api/v1/messages', params: { 'message': newMessage }, headers: header
			end

			it 'return error if forgot something' do
				create_message
				json_response = JSON.parse(response.body)
				expect(json_response['data']).to eq('Revise os dados')
			end
			
			it 'return 422' do
				create_message
				expect(response.status).to eq 422
			end  
		end
	end

	describe 'with master token' do
		describe 'GET /api/v1/messages'  do
			subject(:index_messages) do
				get '/api/v1/messages', headers: headerMaster
			end

			it 'returns all (4) messages' do
				index_messages
				json_response = JSON.parse(response.body)
				expect(json_response['data'].size).to eq 4
			end
			
			it 'return 200' do
				index_messages
				expect(response.status).to eq 200
			end  
		end

		describe 'GET /api/v1/messages/:id'  do
			subject(:show_messages) do
				get '/api/v1/messages/' + message3.id.to_s, headers: headerMaster
			end

			it 'return message with id equal at URI' do
				show_messages
				json_response = JSON.parse(response.body)
				expect(json_response['data']['id']).to eq message3.id
			end
			
			it 'return 200' do
				show_messages
				expect(response.status).to eq 200
			end  
		end

		describe 'GET /api/v1/messages/sent' do
			subject(:sent_messages) do
				get '/api/v1/messages/sent', headers: headerMaster
			end

			it 'return none message sent' do
				sent_messages
				json_response = JSON.parse(response.body)
				expect(json_response['data'].size).to eq 0
			end
			
			it 'return 200' do
				sent_messages
				expect(response.status).to eq 200
			end  
		end
	end

	describe 'without token' do
		describe 'GET /api/v1/messages' do
			subject(:index_messages) do
				get '/api/v1/messages'
			end

			it 'return 401' do
				index_messages
				expect(response.status).to eq 401
			end 
		end
	end
end