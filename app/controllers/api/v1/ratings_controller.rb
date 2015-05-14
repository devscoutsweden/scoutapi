require 'db_constants'
module Api
  module V1
    include Db
    class RatingsController < ApplicationController
      before_filter :restrict_access_to_api_users
      #before_action :load_rating_entity

      def create
        authorize Rating
        Rating.delete_all(
            {
                :user => @userApiKey.user,
                :activity_id => params[:activity_id]
            });

        Rating.create!(
            {
                :user => @userApiKey.user,
                :activity_id => params[:activity_id],
                :rating => get_rating_params[:rating]
            })

        url = api_v1_activity_rating_url({activity_id: get_rating_params[:activity_id]})
        render :nothing => true, status: :created, location: url
      end

      def show
        authorize @rating
        @rating = Rating.find_by!(
            {
                :user => @userApiKey.user,
                :activity_id => params[:activity_id]
            })
        respond_with @rating
      end

      def destroy
        authorize @rating
        result = Rating.delete_all(
            {
                :user => @userApiKey.user,
                :activity_id => params[:activity_id]
            });
        if result
          head :no_content
        else
          error_record_has_invalid_data('Could not delete rating')
        end
      end

      private

      def load_rating_entity
        @rating = Rating.find_or_initialize_by(
            {
                :user => @userApiKey.user,
                :activity_id => params[:activity_id]
            })
      end

      def get_rating_params
        params.permit(:activity_id, :rating)
      end
    end
  end
end
