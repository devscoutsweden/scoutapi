require 'db_constants'
module Api
  module V1
    include Db
    class CategoriesController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:index, :show]
      before_action :set_category, only: [:show, :update, :destroy]
      before_action :load_usage_count, only: [:index, :show]

      def index
        authorize Category
        @categories = Category.all.includes(:media_file).order(:group => :asc, :name => :asc)
        respond_with @categories
      end

      def load_usage_count
        @usageCount = Category.
            joins(:activity_versions).
            where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED).
            group(:category_id).
            count(:activity_versions)
      end

      def create
        authorize Category
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
        authorize @category
        respond_with @category
      end

      def update
        authorize @category
        @category.media_file = get_or_create_media_file()
        @category.assign_attributes(validated_params)
        if @category.save
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
            file = MediaFile.new({:uri => params[:media_file_uri]})
          end
          file
        else
          nil
        end
      end

      def destroy
        authorize @category
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
