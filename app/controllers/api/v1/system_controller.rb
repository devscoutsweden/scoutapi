module Api
  module V1
    class SystemController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:ping]

      def ping
        head :no_content
      end
    end
  end
end
