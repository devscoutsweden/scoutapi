module Api
  module V1
    class CategoriesController < ApplicationController
      before_filter :restrict_access_to_api_users
      before_action :set_category, only: [:show, :update, :destroy]

      def index
        @categories = Category.all.order(:group => :asc, :name => :asc)
        respond_with @categories
      end

      def create
        @category = Category.new(validated_params)
        @category.user = @userApiKey.user
        @category.media_file = get_or_create_media_file()
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
        @category.media_file = get_or_create_media_file()
        if @category.update(validated_params)
          head :no_content
        else
          respond_with @category.errors, status: :unprocessable_entity
        end
      end

      def get_or_create_media_file
        if !params[:media_file_id].nil?
          MediaFile.find(params[:media_file_id])
        elsif !params[:media_file_uri].nil?
          file = MediaFile.find_by_uri(params[:media_file_uri])
          if file.nil?
            file = MediaFile.new({ :uri => params[:media_file_uri] })
          end
          file
        else
          nil
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
        Category.joins("LEFT OUTER JOIN media_files ON media_files.id = categories.media_file_id").includes(:media_file).find(id)
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
