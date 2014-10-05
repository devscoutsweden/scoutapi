module Api
  module V1
    class FavouritesController < ApplicationController
      before_filter :restrict_access_to_api_users

      def index
        favourites = @userApiKey.user.favourite_activities.pluck(:activity_id)
        respond_with favourites
      end

      def update
        user = @userApiKey.user

        # Start be deleting the user's current favourites...
        FavouriteActivity.delete_all(:user => @userApiKey.user)

        if !params[:id].nil? && !params[:id].empty?
          # ...and continue with adding the user's new list of favourites.
          user.favourites << Activity.find(params[:id])
        end

        if user.save!
          head :no_content
        else
          respond_with user.errors, status: :unprocessable_entity
        end
      end

      #private

      #def validated_params
      #  Rails.logger.info("PARAMS: #{params.inspect}")
      #  params.require(:id)
      #end
    end
  end
end
