# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

use Rack::Cors do
  allow do
    origins 'localhost:3000'
    resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :patch, :options]
  end
end

use Rack::Static, :urls => ["/media-file-cache"], :root => 'tmp'

run Rails.application
