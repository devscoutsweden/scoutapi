require 'db_constants'
module Api
  module V1
    include Db
    class ActivitiesController < ApplicationController
      before_filter :restrict_access_to_api_users
      before_action :set_activity, only: [:show, :update, :destroy]
      before_action :init_output_attr_lists, only: [:show, :index, :create]

      def index
        query_conditions = get_find_condition_params

        q = ActivityVersion.
          where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED)

        if query_conditions.has_key?("featured")
          q = q.where(featured: query_conditions[:featured] == "true")
        end

        if params.has_key?("id")
          q = q.where(activity_id: (params[:id].is_a?(Array) ? params[:id] : params[:id].split(',')))
        end

        if query_conditions.has_key?("age_1")
          q = q.where("activity_versions.age_min <= ?", query_conditions[:age_1].to_i)
          q = q.where("? <= activity_versions.age_max ", query_conditions[:age_1].to_i)
        end
        if query_conditions.has_key?("age_2")
          q = q.where("activity_versions.age_min <= ?", query_conditions[:age_2].to_i)
          q = q.where("? <= activity_versions.age_max", query_conditions[:age_2].to_i)
        end

        if query_conditions.has_key?("participants_1")
          q = q.where("activity_versions.participants_min <= ?", query_conditions[:participants_1].to_i)
          q = q.where("? <= activity_versions.participants_max", query_conditions[:participants_1].to_i)
        end
        if query_conditions.has_key?("participants_2")
          q = q.where("activity_versions.participants_min <= ?", query_conditions[:participants_2].to_i)
          q = q.where("? <= activity_versions.participants_max", query_conditions[:participants_2].to_i)
        end

        if query_conditions.has_key?("time_1")
          q = q.where("activity_versions.time_min <= ?", query_conditions[:time_1].to_i)
          q = q.where("? <= activity_versions.time_max", query_conditions[:time_1].to_i)
        end
        if query_conditions.has_key?("time_2")
          q = q.where("activity_versions.time_min <= ?", query_conditions[:time_2].to_i)
          q = q.where("? <= activity_versions.time_max", query_conditions[:time_2].to_i)
        end

        if query_conditions.has_key?("name")
          q = q.where("activity_versions.name LIKE ?", "%#{query_conditions[:name]}%")
        end
        if params.has_key?("categories")
          # The "joins" may not be necessary. The below "includes" may be necessary.
          q = q.joins(:categories).where(categories: { id: (params[:categories].is_a?(Array) ? params[:categories] : params[:categories].split(',')) })
        end
        if query_conditions.has_key?("text")
          q = q.where("activity_versions.name LIKE ? "+
                        "OR " +
                        "activity_versions.descr_introduction LIKE ? "+
                        "OR " +
                        "activity_versions.descr_main LIKE ? "+
                        "OR " +
                        "activity_versions.descr_material LIKE ? "+
                        "OR " +
                        "activity_versions.descr_notes LIKE ? "+
                        "OR " +
                        "activity_versions.descr_prepare LIKE ? "+
                        "OR " +
                        "activity_versions.descr_safety LIKE ?",
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
          ids = q.pluck(:id).sample(query_conditions["random"].to_i)

          # Retrieve data for the activities with the randomly selected ids. Reuse the "q" variable to simplify coding.
          q = get_base_search_query(ActivityVersion).find(ids);
        elsif query_conditions.has_key?("favourites")
          favourites = FavouriteActivity.
            group(:activity_id).
            count(:user_id)

          sorted = favourites.sort_by { |k, v| -v }

          ids = sorted.map { |item| item[0] }.take(query_conditions["favourites"].to_i)

          # Retrieve data for the activities with the randomly selected ids. Reuse the "q" variable to simplify coding.
          q = get_base_search_query(ActivityVersion.where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED).where(:activity_id => ids));
        else
          q = get_base_search_query(q)
        end
        @activityVersions = q;

        # Create hash/map of how many users have marked each activity as a favourite. This information is later used by the views.
        @favouritesCount = get_favourite_count(get_activity_ids(@activityVersions))
      end

      def get_base_search_query(q)
        if !@attrs.include?('categories') && !@attrs.include?('media_files') && !@attrs.include?('references')
          q = q.includes(:activity)
        elsif @attrs.include?('categories') && !@attrs.include?('media_files') && !@attrs.include?('references')
          q = q.includes(:activity, :categories)
        else
          q = q.includes(:activity, :categories, :media_files, :references)
        end
        q.order(:activity_id, :id)
      end

      def init_output_attr_lists
        allowed_activity_version_attrs = [
          'name',
          'descr_introduction',
          'descr_main',
          'descr_material',
          'descr_notes',
          'descr_prepare',
          'descr_safety',
          'featured',
          'age_max',
          'age_min',
          'participants_max',
          'participants_min',
          'time_max',
          'time_min',
          'published_at',
          'status',
          'created_at'
        ]

        if params.has_key?('attrs') && params[:attrs].is_a?(Array)
          @attrs = params[:attrs]
        elsif params.has_key?('attrs') && params[:attrs] == 'limited'
          @attrs = ['name',
                    'descr_introduction',
                    'featured',
                    'age_max',
                    'age_min',
                    'participants_max',
                    'participants_min',
                    'time_max',
                    'time_min',

                    'categories']
        else
          @attrs = allowed_activity_version_attrs + ['categories', 'media_files', 'references']
        end

        @activity_version_attrs = @attrs.nil? ? allowed_activity_version_attrs : @attrs & allowed_activity_version_attrs
      end

      def get_favourite_count(ids)
        FavouriteActivity.
          where(:activity_id => ids).
          group(:activity_id).
          count(:user_id)
      end

      # Extracts the activity ids from the activity versions supplied
      def get_activity_ids(activity_versions)
        ids = Array.new
        activity_versions.each do |a|
          ids << a.activity_id
        end
        ids
      end

      def show
        @all_versions = params.has_key?('all_versions') && params[:all_versions] == 'true'
        # Create hash/map of how many users have marked each activity as a favourite. This information is later used by the views.
        @favouritesCount = get_favourite_count(@activity.id)
        respond_with @activity
      end

      def create
        @activity = Activity.new(status: Db::ActivityVersionStatus::PUBLISHED)
        @activity.user = @userApiKey.user

        # Create hash/map of how many users have marked each activity as a favourite. This information is later used by the views.
        @favouritesCount = get_favourite_count(@activity.id)

        if @activity.save!
          version = ActivityVersion.new(get_activity_version_params)
          version.user = @userApiKey.user
          version.activity = @activity
          version.status = Db::ActivityVersionStatus::PUBLISHED

          if !params[:categories].nil? && !params[:categories].empty?
            version.categories << Category.find(params[:categories])
          end

          if !params[:references].nil? && !params[:references].empty?
            version.references << Reference.find(params[:references])
          end

          if !params[:media_files].nil? && !params[:media_files].empty?
            version.media_files << MediaFile.find(params[:media_files])
          end

          if !params[:media_file_uris].nil? && !params[:media_file_uris].empty?
            params[:media_file_uris].each do |uri|
              version.media_files << get_or_create_media_file(uri)
            end
          end

          version.save!
          respond_with :api, :v1, @activity, status: :created
        else
          respond_with @activity.errors, status: :unprocessable_entity
        end
      end

      def get_or_create_media_file(uri)
        file = MediaFile.find_by_uri(uri)
        if file.nil?
          file = MediaFile.new({ :uri => uri })
        end
        file
      end

      def update
        # Update non-versioned attributes
        # Create new revision
        # Set status of new revision to status of current revision
        # Set status of current revision to PREVIOUSLY_PUBLISHED if it is PUBLISHED

        new_version = ActivityVersion.new(get_activity_version_params)
        new_version.user = @userApiKey.user

        version_to_replace = @activity.activity_versions.order(:id).last

        new_version.status = version_to_replace.status

        if version_to_replace.status == Db::ActivityVersionStatus::PUBLISHED
          # It has happened that multiple versions of a single activity have had
          # PUBLISHED status at the same time. This screws up some queries and
          # must be avoided. Explicitly setting the status for all versions,
          # instead of merely the last one, ensures that this situation will
          # never occur (again).

          ActivityVersion.where(:activity => @activity, :status => Db::ActivityVersionStatus::PUBLISHED).update_all(:status => Db::ActivityVersionStatus::PREVIOUSLY_PUBLISHED)
          #version_to_replace.status = Db::ActivityVersionStatus::PREVIOUSLY_PUBLISHED
        end

        if !params[:categories].nil? && !params[:categories].empty?
          new_version.categories << Category.find(params[:categories])
        end

        if !params[:references].nil? && !params[:references].empty?
          new_version.references << Reference.find(params[:references])
        end

        if !params[:media_files].nil? && !params[:media_files].empty?
          new_version.media_files << MediaFile.find(params[:media_files])
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
          #order("activities.id, activity_versions.id DESC").
          #where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED).
          #includes(:activity_versions, activity_versions: [:references, :categories]).
          find(id)
      end

      def set_activity
        @activity = find_activity(params[:id])
        #@activity.activity_versions.sort! { |a,b| a.id < b.id }
      end

      #def validated_params
      #  Rails.logger.info("PARAMS: #{params.inspect}")
      #  params #.permit(:name, :group)
      #end

      def get_activity_version_params
        params.permit(:name, :descr_introduction, :descr_main, :descr_material, :descr_notes, :descr_prepare, :descr_safety, :age_min, :age_max, :participants_min, :participants_max, :time_min, :time_max)
      end

      def get_find_condition_params
        params.permit(:name, :descr_introduction, :descr_main, :descr_material, :descr_notes, :descr_prepare, :descr_safety, :age_1, :age_2, :participants_1, :participants_2, :time_1, :time_2, :featured, :text, :random, :favourites, :categories)
      end
    end
  end
end
