class WebPagesController < ApplicationController
  def index
    skip_authorization
  end
end
