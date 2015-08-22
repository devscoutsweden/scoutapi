source 'https://rubygems.org'

ruby '2.0.0'

gem 'tzinfo-data', '1.2015.4', platforms: [:mingw, :mswin, :x64_mingw]

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'

# Use postgresql as the database for Active Record
gem 'pg', :group => :production
gem 'sqlite3', :group => :development
#gem 'rails_12factor', :group => :production # Used by Heroku. Heroku integration has previously relied on using the Rails plugin system, which has been removed from Rails 4. To enable features such as static asset serving and logging on Heroku please add rails_12factor gem to your Gemfile.
gem 'thin', :group => :production

# Must use https://github.com/Nerian/google-id-token instead of official "because the original one is
# outdated" (source: http://dev.mikamai.com/post/101852140929/google-device-authentication-in-your-rails-app)
gem 'google-id-token', git: 'https://github.com/Nerian/google-id-token.git'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
#gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
#gem 'coffee-rails', '~> 4.0.0'
#gem 'coffee-script', '2.2.0'
#gem 'coffee-script-source', '1.8.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '3.1.2'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '2.2.16'
# bundle exec rake doc:rails generates the API under doc/api.
#gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn', '~> 4.9.0', :group => :production

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# Use Pundit for authorization
gem 'pundit', '1.0.0'

gem 'rack-cors', :require => 'rack/cors'

gem 'json', '1.8.2'