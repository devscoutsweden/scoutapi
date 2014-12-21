require 'google-id-token'

class ApplicationController < ActionController::Base
  respond_to :json
  rescue_from ActiveRecord::RecordNotUnique, :with => :error_record_not_unique
  rescue_from ActiveRecord::RecordNotFound, :with => :error_record_not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :error_record_has_invalid_data

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

  ANDROID_APP_DEBUG_CLIENT_ID = '551713736410-24qc0q33hkq43sebfv3r7dio6h0totq8.apps.googleusercontent.com'
  WEB_CLIENT_ID = '551713736410-q55omfobgs9j8ia4ae3r7sbi20vcvt49.apps.googleusercontent.com'

  def restrict_access_to_api_users
    authenticate_or_request_with_http_token do |token, options|
      Rails.logger.info("restrict_access_to_api_users: #{token} #{options}")
      case options.type
        when 'apikey'
          Rails.logger.info("Authenticate using API key #{token}")
          @userApiKey = UserApiKey.find_by_key(token)
        when 'google'
          Rails.logger.info("Authenticate using Google ID Token #{token}")
          #  Verify Google token. This will return a Google user id.
          validator = GoogleIDToken::Validator.new
          jwt = validator.check(token,
                                WEB_CLIENT_ID,
                                WEB_CLIENT_ID)
          Rails.logger.info("Google JWT: #{jwt}")
          if jwt
            #  Return an API key for the user with that Google user id.
            identity = UserIdentity.where(type: 'google-id', data: jwt['sub'])
            if identity
              Rails.logger.info("Identity found")
              @userApiKey = identity.user.user_api_keys.first
            else
              Rails.logger.info('User is authenticated Google user but has not been mapped to a user in the system')
              #  User is authenticated Google user but has not been mapped to a user in the system
              @user = User.new(display_name: jwt['email'], email: jwt['email'], email_verified: true)
              identity = UserIdentity.new(type: 'google-id', data: jwt['sub'])
              identity.user = @user
              @user.user_identities << identity
              @userApiKey = UserApiKey.new()
              @userApiKey.user = @user
              @user.user_api_keys << apiKey

              Rails.logger.info('Have create in-memory objects for User, UserIdentity and UserApiKey.')

              if @user.save!
                Rails.logger.info('Saved user')
                response.headers['X-ScoutAPI-APIKey'] = @userApiKey.key
                Rails.logger.info("Will return API key #{@userApiKey.key}")
                @userApiKey
              else
                Rails.logger.error('Failed to save user')
                respond_with @user.errors, status: :unprocessable_entity
              end
            end
          else
            Rails.logger.error('Invalid Google ID token')
            error_forbidden('Invalid Google ID token')
          end
        else
          Rails.logger.error('Unsupported token type')
          error_record_has_invalid_data('Unsupported token type')
      end
    end
  end

  private

  def error_forbidden(error)
    render_error error, 'Access to this URL is denied', :forbidden
  end

  def error_record_not_unique(error)
    render_error error, 'The input values conflict with another object. Perhaps the name is already taken?', :unprocessable_entity
  end

  def error_record_not_found(error)
    render_error error, 'The requested object does not exist.', :not_found
  end

  def error_record_has_invalid_data(error)
    render_error error, 'Invalid input data.', :unprocessable_entity
  end

  def render_error(error, message, response_code)
    Rails.logger.info("error: #{error.inspect}")
    render :json => {:error => message, :details => error.to_s}, :status => response_code
  end

end
