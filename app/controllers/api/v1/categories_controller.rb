module Api
  module V1
    class CategoriesController < ApplicationController
      before_filter :restrict_access_to_api_users
      before_action :set_category, only: [:show, :update, :destroy]

      def index
        @categories = Category.all
        respond_with @categories
      end

      def create
        @category = Category.new(validated_params)
        @category.user = @userApiKey.user
        if @category.save
          respond_with :api, :v1, @category, status: :created
        else
          respond_with @category.errors, status: :unprocessable_entity
        end
      end

      def show
        respond_with @category
      end

      def update
        if @category.update(validated_params)
          head :no_content
        else
          respond_with @category.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @category.destroy
          head :no_content
        else
          respond_with @category.errors, status: :internal_server_error
        end
      end

      private

      def find_category(id)
        Category.find(id)
      end

      def set_category
        @category = find_category(params[:id])
      end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        params.permit(:name, :group)
      end
    end
  end
end
