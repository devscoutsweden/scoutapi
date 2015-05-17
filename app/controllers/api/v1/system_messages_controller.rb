module Api
  module V1
    class SystemMessagesController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:index]
      before_action :set_system_message, only: [:show, :update, :destroy]

      def index
        skip_authorization
        p = params

        users = SystemMessage.where("id IS NOT NULL")
        if p.has_key?('key')
          p[:key] = [p[:key]] unless p[:key].is_a?(Array)
          query = (['key LIKE ?'] * p[:key].count).join(' OR ')
          values = p[:key].map { |k| k + '%' }
          users = users.where(query, *values)
        end
        case p[:valid]
          when 'now'
            users = users.where('validTo IS NULL OR validTo > ?', DateTime.now)
            users = users.where('validFrom IS NULL OR validFrom < ?', DateTime.now)
          when 'now_and_future'
            users = users.where('validTo IS NULL OR validTo > ?', DateTime.now)
        end

        respond_with users
      end

      def create
        authorize SystemMessage
        @systemMessage = SystemMessage.new(validated_params)
        @systemMessage.user = @userApiKey.user
        if @systemMessage.save
          respond_with :api, :v1, @systemMessage, status: :created
        else
          respond_with @systemMessage.errors, status: :unprocessable_entity
        end
      end

      def show
        authorize @systemMessage
        respond_with @systemMessage
      end

      def update
        authorize @systemMessage
        if @systemMessage.update(validated_params)
          head :no_content
        else
          respond_with @systemMessage.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @systemMessage
        if @systemMessage.destroy
          head :no_content
        else
          respond_with @systemMessage.errors, status: :internal_server_error
        end
      end

      private

      def find_system_message(id)
        SystemMessage.find(id)
      end

      def set_system_message
        @systemMessage = find_system_message(params[:id])
      end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        params.permit(:key, :value, :validTo, :validFrom)
      end
    end
  end
end
