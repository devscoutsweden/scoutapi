require 'google-id-token'

class ApplicationController < ActionController::Base
  include Pundit # Pundit is the authorization module

  respond_to :json

  after_action :verify_authorized # Make sure that all controller actions invoke either authorize or skip_authorization.

  # CORS support thanks to https://gist.github.com/dhoelzgen/cd7126b8652229d32eb4 and http://blog.rudylee.com/2013/10/29/rails-4-cors/
  # Possible alternate solution: http://stackoverflow.com/questions/29751115/how-to-enable-cors-in-rails-4-app

  skip_before_filter :verify_authenticity_token
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS, PATCH'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token, X-ScoutAPI-APIKey'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS, PATCH'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Authorization, Token, X-ScoutAPI-APIKey'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end

  rescue_from ActiveRecord::RecordNotUnique, :with => :error_record_not_unique
  rescue_from ActiveRecord::RecordNotFound, :with => :error_record_not_found
  rescue_from ActiveRecord::RecordInvalid, :with => :error_record_has_invalid_data
  rescue_from Pundit::NotAuthorizedError, :with => :error_unauthorized_role # Print short error message, instead of default stack trace in HTML format, when user is not authorized to invoke an operation.

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  protected

  WEB_CLIENT_ID = '551713736410-q55omfobgs9j8ia4ae3r7sbi20vcvt49.apps.googleusercontent.com'

  AUTH_TYPE_API_KEY = 'apikey'
  AUTH_TYPE_GOOGLE = 'google'

  HTTP_HEADER_APIKEY = 'X-ScoutAPI-APIKey'

  # The current_user method is required by Pundit
  def current_user
    if @userApiKey.nil?
      nil
    else
      @userApiKey.user
    end
  end

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
            jwt = validator.check(token, WEB_CLIENT_ID)
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
              error_unauthorized('Invalid Google ID token')
            end
          rescue JWT::ExpiredSignature
            Rails.logger.error('Signature has expired')
            error_unauthorized('Signature has expired')
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

  def error_unauthorized(error)
    render_error error, 'You must provide credentials', :unauthorized
  end

  def error_unauthorized_role
    render_error 'Your role does not grant you permission to this operation', 'You are not authorized', :forbidden
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
