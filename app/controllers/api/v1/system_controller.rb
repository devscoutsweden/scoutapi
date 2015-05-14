module Api
  module V1
    class SystemController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:ping]

      def ping
        authorize :system
        head :no_content
      end

      def roles
        authorize :system
        roles = { permission_levels: ApplicationPolicy::PERMISSIONS, role_levels: User.roles }
        respond_with roles
      end
    end
  end
end
