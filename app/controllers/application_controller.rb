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
  ANDROID_APP_RELEASE_CLIENT_ID = '551713736410-959bfbeh3rv79dsiu112q6de1kj3tdak.apps.googleusercontent.com'
  MAX_TIMJE_WEB_CLIENT_ID = '139070892429-g1q9l9jcntanab94duoe9ae01dd5kub7.apps.googleusercontent.com'
  WEB_CLIENT_ID = '551713736410-q55omfobgs9j8ia4ae3r7sbi20vcvt49.apps.googleusercontent.com'

  AUTH_TYPE_API_KEY = 'apikey'
  AUTH_TYPE_GOOGLE = 'google'

  HTTP_HEADER_APIKEY = 'X-ScoutAPI-APIKey'

  def restrict_access_to_api_users_if_credentials_supplied
    restrict_access_to_api_users if request.authorization
  end

  def restrict_access_to_api_users
    authenticate_or_request_with_http_token do |token, options|
      Rails.logger.info("restrict_access_to_api_users: #{token} #{options}")
      type = options.has_key?('type') ? options['type'] : AUTH_TYPE_API_KEY
      case type
        when AUTH_TYPE_API_KEY
          Rails.logger.info("Authenticate using API key #{token}")
          @userApiKey = UserApiKey.find_by_key(token)
        when AUTH_TYPE_GOOGLE
          Rails.logger.info("Authenticate using Google ID Token #{token}")
          #  Verify Google token. This will return a Google user id.
          validator = GoogleIDToken::Validator.new
          begin
            clientIds = Array[ANDROID_APP_RELEASE_CLIENT_ID, ANDROID_APP_DEBUG_CLIENT_ID, MAX_TIMJE_WEB_CLIENT_ID]
            # Check Google ID token and compare it's client id to all known/accepted client ids. Use first non-nil result from check(...).
            jwt = clientIds.map { |clientId| validator.check(token, WEB_CLIENT_ID, clientId) }.compact.first
            if jwt
              #  Return an API key for the user with that Google user id.
              identity = UserIdentity.find_by(type: 'google-id', data: jwt['sub'])
              if identity
                Rails.logger.info("Identity found")
                apiKey = identity.user.user_api_keys.first
                response.headers[HTTP_HEADER_APIKEY] = apiKey.key
                @userApiKey = apiKey
              else
                Rails.logger.info('User is authenticated Google user but has not been mapped to a user in the system')
                #  User is authenticated Google user but has not been mapped to a user in the system
                @user = User.new(display_name: jwt['email'], email: jwt['email'], email_verified: true)
                identity = UserIdentity.new(type: 'google-id', data: jwt['sub'])
                identity.user = @user
                @user.user_identities << identity
                @userApiKey = UserApiKey.new()
                @userApiKey.user = @user
                @user.user_api_keys << @userApiKey

                Rails.logger.debug('Have created in-memory objects for User, UserIdentity and UserApiKey.')

                if @user.save!
                  Rails.logger.info("Saved user. Set API key to #{@userApiKey.key}")
                  response.headers[HTTP_HEADER_APIKEY] = @userApiKey.key
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
          rescue JWT::ExpiredSignature
            Rails.logger.error('Signature has expired')
            error_forbidden('Signature has expired')
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
