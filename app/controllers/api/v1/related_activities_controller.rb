require 'db_constants'
module Api
  module V1
    include Db
    class RelatedActivitiesController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:index]
      before_action :set_related_activity, only: [:destroy]

      def index
        authorize ActivityRelation
        @related_activities = ActivityRelation.where(:activity_id => params[:activity_id])
        respond_with @related_activities
      end

      def create
        @related_activity = ActivityRelation.new(validated_params)
        @related_activity.user = @userApiKey.user

        authorize @related_activity

        if @related_activity.save
          respond_with :api, :v1, @related_activity, status: :created
        else
          respond_with @related_activity.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @related_activity
        if @related_activity.destroy
          head :no_content
        else
          respond_with @related_activity.errors, status: :internal_server_error
        end
      end

      def set_auto_generated
        authorize ActivityRelation
        #activity = Activity.find(params[:activity_id])
        ActivityRelation.delete_all({
                                        :is_auto_generated => true,
                                        :activity_id => params[:activity_id]
                                    })
        if !params[:related_activity_ids].nil? && !params[:related_activity_ids].empty?
          params[:related_activity_ids].each do |related_activity_id|
            @related_activity = ActivityRelation.new(validated_params)
            @related_activity.user = @userApiKey.user
            @related_activity.related_activity_id = related_activity_id
            @related_activity.is_auto_generated = true
            @related_activity.save!
          end
        end
        head :no_content
      end

      private

      def find_related_activity(id)
        ActivityRelation.find(id)
      end

      def set_related_activity
        @related_activity = find_related_activity(params[:id])
      end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        params.permit(:activity_id, :related_activity_id, :is_auto_generated)
      end
    end
  end
end
