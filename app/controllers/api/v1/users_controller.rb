module Api
  module V1
    class UsersController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:all_api_keys]
      before_action :set_user, only: [:show, :update, :destroy]

      #def index
      #  @users = User.all
      #  respond_with @users
      #end

      def create
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
        respond_with @userApiKey.user
      end

      def all_api_keys
        if Rails.env.development?
          @users = User.all
          respond_with @users
        else
          error_forbidden('Feature only available in development mode.')
        end
      end

      #def show
      #  respond_with @user
      #end

      #def update
      #  if @user.update(validated_params)
      #    head :no_content
      #  else
      #    respond_with @user.errors, status: :unprocessable_entity
      #  end
      #end

      def update_profile
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

      #def find_user(id)
      #  User.find(id)
      #end

      #def set_user
      #  @user = find_user(params[:id])
      #end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        params.permit(:display_name, :email)
      end
    end
  end
end
