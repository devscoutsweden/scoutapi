module Api
  module V1
    class MediaFilesController < ApplicationController
      before_action :set_media_file, only: [:show, :update, :destroy]

      def index
        @media_files = MediaFile.all
        respond_with @media_files
      end

      def create
        @media_file = MediaFile.new(validated_params)
        if @media_file.save
          respond_with :api, :v1, @media_file, status: :created
        else
          respond_with @media_file.errors, status: :unprocessable_entity
        end
      end

      def show
        respond_with @media_file
      end

      def update
        if @media_file.update(validated_params)
          head :no_content
        else
          respond_with @media_file.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @media_file.destroy
          head :no_content
        else
          respond_with @media_file.errors, status: :internal_server_error
        end
      end

      private

      def find_media(id)
        MediaFile.find(id)
      end

      def set_media_file
        @media_file = find_media(params[:id])
      end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        params.permit(:mime_type, :data, :uri, :status)
      end
    end
  end
end
