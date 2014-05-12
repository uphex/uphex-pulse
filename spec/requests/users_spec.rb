require 'environment_spec_helper'

describe "users" do
  context "signing up" do
    it "signs up" do
      set_csrf_token 'foo'
      post '/users',
        :authenticity_token => 'foo',
        :user => {
          :name => 'x',
          :email => 'y',
          :password => 'z'
        }
      expect(last_response.status).to eq 302
      expect(last_response.headers['Location']).to end_with '/users/me/dashboard'
    end

    it "prevents multiple accounts with the same email" do
      set_csrf_token 'foo'
      post '/users',
           :authenticity_token => 'foo',
           :user => {
               :name => 'x',
               :email => 'y',
               :password => 'z'
           }
      post '/users/me/session',{
          :authenticity_token => 'foo',
          :_method=>'DELETE'
      }
      post '/users',
           :authenticity_token => 'foo',
           :user => {
               :name => 'x',
               :email => 'y',
               :password => 'z'
           }
      expect(last_response.body).to include "already been taken"
    end

    it "prevents signing up withou a name, email os password" do
      set_csrf_token 'foo'
      post '/users',
           :authenticity_token => 'foo',
           :user => {
               :email => 'y',
               :password => 'z'
           }

      expect(last_response.body).to include "blank"
      post '/users',
           :authenticity_token => 'foo',
           :user => {
               :name => 'x',
               :password => 'z'
           }

      expect(last_response.body).to include "blank"
      post '/users',
           :authenticity_token => 'foo',
           :user => {
               :name => 'x',
               :email => 'y'
           }

      expect(last_response.body).to include "blank"
    end
  end

  context "signing in and out" do
    it "signs in and out" do
      create_sample_user
      get '/'
      follow_redirect!
      expect(last_response.body).to include "Log out"

      post '/users/me/session',{
          :authenticity_token => 'foo',
          :_method=>'DELETE'
      }
      follow_redirect!
      expect(last_response.body).to include "Signed out"

      post '/sessions',{
          :authenticity_token => 'foo',
          :user=>{
              :email=>'test_email',
              :password=>'wrong password'
          }
      }

      follow_redirect!
      expect(last_response.body).to include "Authentication failure"

      post '/sessions',{
          :authenticity_token => 'foo',
          :user=>{
              :email=>'test_email',
              :password=>'test_password'
          }
      }
      follow_redirect!
      expect(last_response.body).to include "Signed in"

    end
  end

  context "view and modify profile" do
    it "views the profile informations" do
      create_sample_user
      get '/users/me'
      expect(last_response.body).to include "test_user"
      expect(last_response.body).to include "test_email"

      put '/users/me',{
          :authenticity_token => 'foo',
          :user=>{
              :name=>'new_name',
              :email=>'new_email'
          }
      }

      get '/users/me'
      expect(last_response.body).to include "new_name"
      expect(last_response.body).to include "new_email"

      put '/users/me',{
          :authenticity_token => 'foo',
          :user=>{
              :password=>'new_password'
          }
      }

      post '/users/me/session',{
          :authenticity_token => 'foo',
          :_method=>'DELETE'
      }

      post '/sessions',{
          :authenticity_token => 'foo',
          :user=>{
              :email=>'new_email',
              :password=>'new_password'
          }
      }
      follow_redirect!
      expect(last_response.body).to include "Signed in"

    end
  end

  context "view and modify account" do
    it "views and modify account informations" do
      create_sample_user
      get '/accounts/me'
      expect(last_response.body).to include "test_user Inc."

      put '/accounts/me',{
          :authenticity_token => 'foo',
          :organization=>{
              :name=>'new_org'
          }
      }

      follow_redirect!
      expect(last_response.body).to include "Account modified"

      get '/accounts/me'
      expect(last_response.body).to include "new_org"
    end
  end

end
