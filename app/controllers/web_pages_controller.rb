class WebPagesController < ApplicationController
  def index
    skip_authorization
  end

  def admin
    skip_authorization
  end
end
