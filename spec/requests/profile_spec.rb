require 'rails_helper'

RSpec.describe Api::V1::ProfilesController do
	let(:user) { FactoryBot.create(:user) }
	let(:master) { FactoryBot.create(:user, :master) }
	let(:header) do
		{ 'Authorization': user.token }
	end
	let(:headerMaster) do
		{ 'Authorization': master.token }
	end

	describe 'with normal token' do
		describe 'GET /api/v1/profile'  do
			subject(:index_profile) do
				get '/api/v1/profile', headers: header
			end

			it 'return user profile' do
				index_profile
				json_response = JSON.parse(response.body)
				expect(json_response['data']['name']).to eq(user.name)
			end
			
			it 'return 200' do
				index_profile
				expect(response.status).to eq 200
			end  
		end

		describe 'PATCH /api/v1/profile' do
			let(:editProfileName) do
				{ 
					'name': 'John'
				}
			end

			subject(:edit_profile) do
				patch '/api/v1/profile', params: { 'user': editProfileName }, headers: header
			end
			
			subject(:index_profile) do
				get '/api/v1/profile', headers: header
			end

			it 'return that everything ocurred as planned when changing name' do
				edit_profile
				json_response = JSON.parse(response.body)
				expect(json_response['data']).to eq('Perfil editado com sucesso.')
			end

			it 'verify that the name has changed' do
				edit_profile
				index_profile
				json_response = JSON.parse(response.body)
				expect(json_response['data']['name']).not_to eq(user.name)
			end
			
			it 'return 200' do
				edit_profile
				expect(response.status).to eq 200
			end  
		end

		describe 'PATCH /api/v1/profile' do
			let(:editProfilePasswordWrong) do
				{ 
					'password': '123456'
				}
			end

			subject(:edit_profile) do
				patch '/api/v1/profile', params: { 'user': editProfilePasswordWrong }, headers: header
			end

			it 'return error message because cant change password without confirmation' do
				edit_profile
				json_response = JSON.parse(response.body)
				expect(json_response['data']).to eq('Revise se a senha foi corretamente digitada duas vezes.')
			end
			
			it 'return 422' do
				edit_profile
				expect(response.status).to eq 422
			end  
		end

		describe 'PATCH /api/v1/profile' do
			let(:editProfilePasswordCorrect) do
				{ 
					'password': '123456a',
					'password_confirmation': '123456a'
				}
			end

			subject(:edit_profile) do
				patch '/api/v1/profile', params: { 'user': editProfilePasswordCorrect }, headers: header
			end

			it 'return that everything ocurred as planned when changing password' do
				edit_profile
				json_response = JSON.parse(response.body)
				expect(json_response['data']).to eq('Perfil editado com sucesso.')
			end
			
			it 'return 200' do
				edit_profile
				expect(response.status).to eq 200
			end  
		end
	end

	describe 'with master token' do
		describe 'GET /api/v1/profile'  do
			subject(:index_profile) do
				get '/api/v1/profile', headers: header
			end

			it 'return user profile' do
				index_profile
				json_response = JSON.parse(response.body)
				expect(json_response['data']['name']).to eq(user.name)
			end
			
			it 'return 200' do
				index_profile
				expect(response.status).to eq 200
			end  
		end
	end

	describe 'without token' do
		describe 'GET /api/v1/profile' do
			subject(:index_profile) do
				get '/api/v1/profile'
			end

			it 'return 401' do
				index_profile
				expect(response.status).to eq 401
			end 
		end
	end
end