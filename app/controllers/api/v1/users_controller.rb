module Api
  module V1
    class UsersController < ApplicationController
      before_filter :restrict_access_to_api_users
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        authorize User
        p = validated_params

        users = User
        users = users.where("LOWER(display_name) LIKE ?", "%#{p[:display_name].mb_chars.downcase.to_s}%") if p.has_key?('display_name')
        users = users.where("LOWER(email) LIKE ?", "%#{p[:email].mb_chars.downcase.to_s}%") if p.has_key?('email')
        users = users.where(role: p[:role]) if p.has_key?('role')

        respond_with users
      end

      def create
        authorize User
        @user = User.new(validated_params)
        apiKey = UserApiKey.new()
        apiKey.user = @user
        @user.user_api_keys << apiKey

        if @user.save!
          respond_with :api, :v1, @user, status: :created
        else
          respond_with @user.errors, status: :unprocessable_entity
        end
      end

      def profile
        authorize User
        respond_with @userApiKey.user
      end

      def all_api_keys
        authorize User
        if Rails.env.development?
          @users = User.all
          respond_with @users
        else
          error_forbidden('Feature only available in development mode.')
        end
      end

      def show
        authorize @user
        respond_with @user
      end

      def update
        authorize @user
        if @user.update(validated_params)
          head :no_content
        else
          respond_with @user.errors, status: :unprocessable_entity
        end
      end

      def update_profile
        authorize @userApiKey.user
        if @userApiKey.user.update(validated_params)
          head :no_content
        else
          respond_with @userApiKey.user.errors, status: :unprocessable_entity
        end
      end

      #def destroy
      #  if @user.destroy
      #    head :no_content
      #  else
      #    respond_with @user.errors, status: :internal_server_error
      #  end
      #end

      private

      def find_user(id)
        User.find(id)
      end

      def set_user
        @user = find_user(params[:id])
      end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        p = params.permit(:display_name, :email, :role)

        # If user has specified a role, make sure the role doesn't have a higher level than the user's current role.
        # Incorrect role names are ignored at this point but will later be rejected by ActiveRecord.
        p[:role] = [User.roles[p[:role]], User.roles[@userApiKey.user.role]].min unless (p[:role].nil? || !User.roles.keys.include?(p[:role]))

        p
      end
    end
  end
end
