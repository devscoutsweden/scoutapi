class ApplicationController < ActionController::Base
  respond_to :json
  rescue_from ActiveRecord::RecordNotUnique, :with => :error_record_not_unique
  rescue_from ActiveRecord::RecordNotFound, :with => :error_record_not_found

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  private

  def error_record_not_unique(error)
    render_error error, 'The input values conflict with another object. Perhaps the name is already taken?', :unprocessable_entity
  end

  def error_record_not_found(error)
    render_error error, 'The requested object does not exist.', :not_found
  end

  def render_error(error, message, response_code)
    Rails.logger.info("error: #{error.inspect}")
    render :json => {:error => message}, :status => response_code
  end

end
