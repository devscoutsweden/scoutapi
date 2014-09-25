module Api
  module V1
    class ReferencesController < ApplicationController
      before_action :set_reference, only: [:show, :update, :destroy]

      def index
        @references = Reference.all
        respond_with @references
      end

      def create
        @reference = Reference.new(validated_params)
        if @reference.save
          respond_with :api, :v1, @reference, status: :created
        else
          respond_with @reference.errors, status: :unprocessable_entity
        end
      end

      def show
        respond_with @reference
      end

      def update
        if @reference.update(validated_params)
          head :no_content
        else
          respond_with @reference.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if @reference.destroy
          head :no_content
        else
          respond_with @reference.errors, status: :internal_server_error
        end
      end

      private

      def find_category(id)
        Reference.find(id)
      end

      def set_reference
        @reference = find_category(params[:id])
      end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        params.permit(:uri, :description)
      end
    end
  end
end
