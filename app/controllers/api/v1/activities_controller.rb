require 'db_constants'
module Api
  module V1
    include Db
    class ActivitiesController < ApplicationController
      before_filter :restrict_access_to_api_users
      before_action :set_activity, only: [:show, :update, :destroy]

      def index
        query_conditions = get_find_condition_params

        q = ActivityVersion.
          where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED)

        if query_conditions.has_key?("featured")
          q = q.where(featured: query_conditions[:featured] == "true")
        end
        if query_conditions.has_key?("age_min")
          q = q.where("age_min >= ?", query_conditions[:age_min].to_i)
        end
        if query_conditions.has_key?("age_max")
          q = q.where("age_max <= ?", query_conditions[:age_max].to_i)
        end
        if query_conditions.has_key?("participants_min")
          q = q.where("participants_min >= ?", query_conditions[:participants_min].to_i)
        end
        if query_conditions.has_key?("participants_max")
          q = q.where("participants_max <= ?", query_conditions[:participants_max].to_i)
        end
        if query_conditions.has_key?("time_min")
          q = q.where("time_min >= ?", query_conditions[:time_min].to_i)
        end
        if query_conditions.has_key?("time_max")
          q = q.where("time_max <= ?", query_conditions[:time_max].to_i)
        end
        if query_conditions.has_key?("name")
          q = q.where("name LIKE ?", "%#{query_conditions[:name]}%")
        end
        if params.has_key?("categories")
          # The "joins" may not be necessary. The below "includes" may be necessary.
          q = q.joins(:categories).where(categories: { id: params[:categories]})
        end
        if query_conditions.has_key?("text")
          q = q.where("name LIKE ? "+
                        "OR " +
                        "descr_introduction LIKE ? "+
                        "OR " +
                        "descr_main LIKE ? "+
                        "OR " +
                        "descr_material LIKE ? "+
                        "OR " +
                        "descr_notes LIKE ? "+
                        "OR " +
                        "descr_prepare LIKE ? "+
                        "OR " +
                        "descr_safety LIKE ?",
                      "%#{query_conditions[:text]}%",
                      "%#{query_conditions[:text]}%",
                      "%#{query_conditions[:text]}%",
                      "%#{query_conditions[:text]}%",
                      "%#{query_conditions[:text]}%",
                      "%#{query_conditions[:text]}%",
                      "%#{query_conditions[:text]}%")
        end

        if query_conditions.has_key?("random")
          # Searching for random activities requires one additional SQL query,
          # compared to returning all activites matching the given conditions.
          # The first query performs the filtering but only returns the primary
          # key values for the matching activities. The second query, which
          # returns the actual activity data, then uses randomly selected values
          # returned from the first query to identify which records to return.

          # Perform search and return the ids of all matching activities. Then
          # select N random values from this list of primary keys. The stress on
          # the database is lessened by only having to return the ids.
          q = q.pluck(:id).sample(query_conditions["random"].to_i)

          # Retrieve data for the activities with the randomly selected ids. Reuse the "q" variable to simplify coding.
          q = ActivityVersion.includes(:activity, :references, :categories).find(q);
        else
          q = q.includes(:activity, :references, :categories)
        end
        @activityVersions = q;
      end

      def show
        @all_versions = params.has_key?('all_versions') && params[:all_versions] == 'true'
        respond_with @activity
      end

      def create
        @activity = Activity.new(status: Db::ActivityVersionStatus::PUBLISHED)
        if @activity.save!
          version = ActivityVersion.new(get_activity_version_params)
          version.activity = @activity
          version.status = Db::ActivityVersionStatus::PUBLISHED

          if !params[:categories].nil? && !params[:categories].empty?
            version.categories << Category.find(params[:categories])
          end

          if !params[:references].nil? && !params[:references].empty?
            version.references << Reference.find(params[:references])
          end

          version.save!
          respond_with :api, :v1, @activity, status: :created
        else
          respond_with @activity.errors, status: :unprocessable_entity
        end
      end

      def update
        # Update non-versioned attributes
        # Create new revision
        # Set status of new revision to status of current revision
        # Set status of current revision to PREVIOUSLY_PUBLISHED if it is PUBLISHED

        new_version = ActivityVersion.new(get_activity_version_params)
        new_version.status = @activity.activity_versions.last.status

        version_to_replace = @activity.activity_versions.last

        if version_to_replace.status == Db::ActivityVersionStatus::PUBLISHED
          version_to_replace.status = Db::ActivityVersionStatus::PREVIOUSLY_PUBLISHED
        end

        if !params[:categories].nil? && !params[:categories].empty?
          new_version.categories << Category.find(params[:categories])
        end

        if !params[:references].nil? && !params[:references].empty?
          new_version.references << Reference.find(params[:references])
        end

        new_version.activity = @activity

        if new_version.save!
          version_to_replace.save!
          head :no_content
        else
          respond_with new_version.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @activity.activity_versions.each { |v|
          v.categories.clear
          v.references.clear
        }
        if @activity.destroy
          head :no_content
        else
          respond_with @activity.errors, status: :internal_server_error
        end
      end

      private

      def find_activity(id)
        Activity.
          #joins(:activity_versions).
          #where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED).
          #includes(:activity_versions, activity_versions: [:references, :categories]).
          find(id)
      end

      def set_activity
        @activity = find_activity(params[:id])
      end

      #def validated_params
      #  Rails.logger.info("PARAMS: #{params.inspect}")
      #  params #.permit(:name, :group)
      #end

      def get_activity_version_params
        params.permit(:name, :descr_introduction, :descr_main, :descr_material, :descr_notes, :descr_prepare, :descr_safety, :age_min, :age_max, :participants_min, :participants_max, :time_min, :time_max)
      end

      def get_find_condition_params
        params.permit(:name, :descr_introduction, :descr_main, :descr_material, :descr_notes, :descr_prepare, :descr_safety, :age_min, :age_max, :participants_min, :participants_max, :time_min, :time_max, :featured, :text, :random, :categories)
      end
    end
  end
end
