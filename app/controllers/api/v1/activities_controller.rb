require 'db_constants'
module Api
  module V1
    include Db
    class ActivitiesController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:index, :show]
      before_filter :restrict_access_to_api_users_if_credentials_supplied, only: [:index, :show]
      before_action :set_activity, only: [:show, :update, :destroy]
      before_action :init_output_attr_lists, only: [:show, :index, :create]

      ACTIVITY_RATINGS_STATS_SQL = Rating.select('activity_id, count(*) ratings_count, avg(rating) ratings_average').group(:activity_id).to_sql

      ACTIVITY_FAVOURITES_STATS_SQL = FavouriteActivity.select('activity_id, count(*) favourite_count').group(:activity_id).to_sql

      def index
        query_conditions = get_find_condition_params

        if @userApiKey.nil? && query_conditions.has_key?('my_favourites')
          error_unauthorized('You cannot search for your personal favourites when you have not provided any authentication credentials')
          return
        end
        if query_conditions.empty?
          error_record_has_invalid_data('You must specify at least one search condition')
          return
        end

        if query_conditions.has_key?("my_favourites") && query_conditions[:my_favourites] != 'false'
          onlyPersonalFavourites = true
        end

        q = get_base_search_query(onlyPersonalFavourites)
        q = q.where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED)

        if query_conditions.has_key?("featured")
          q = q.where(featured: query_conditions[:featured] == "true")
        end

        if query_conditions.has_key?("id")
          q = q.where(activity_id: (query_conditions[:id].is_a?(Array) ? query_conditions[:id] : query_conditions[:id].split(',')))
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
          q = q.where("LOWER(activity_versions.name) LIKE ?", "%#{query_conditions[:name].mb_chars.downcase.to_s}%")
        end
        if query_conditions.has_key?("categories")
          # The "joins" may not be necessary. The below "includes" may be necessary.
          categoryIds = query_conditions[:categories].is_a?(Array) ? query_conditions[:categories].map(&:to_i) : query_conditions[:categories].split(',').map(&:to_i)
          q = q.where("EXISTS (SELECT * FROM activity_versions_categories avc WHERE avc.activity_version_id = activity_versions.id AND avc.category_id IN (?))", categoryIds)
          #q = q.joins(:categories).where(categories: {id: (params[:categories].is_a?(Array) ? params[:categories] : params[:categories].split(','))})
        end
        if query_conditions.has_key?("ratings_count_min")
          q = q.where("r.ratings_count >= ?", query_conditions[:ratings_count_min].to_i)
        end
        if query_conditions.has_key?("ratings_average_min")
          q = q.where("r.ratings_average >= ?", query_conditions[:ratings_average_min].to_f)
        end
        if query_conditions.has_key?("text")
          q = q.where("LOWER(activity_versions.name) LIKE ? "+
                          "OR " +
                          "LOWER(activity_versions.descr_introduction) LIKE ? "+
                          "OR " +
                          "LOWER(activity_versions.descr_main) LIKE ? "+
                          "OR " +
                          "LOWER(activity_versions.descr_material) LIKE ? "+
                          "OR " +
                          "LOWER(activity_versions.descr_notes) LIKE ? "+
                          "OR " +
                          "LOWER(activity_versions.descr_prepare) LIKE ? "+
                          "OR " +
                          "LOWER(activity_versions.descr_safety) LIKE ?",
                      "%#{query_conditions[:text].mb_chars.downcase.to_s}%",
                      "%#{query_conditions[:text].mb_chars.downcase.to_s}%",
                      "%#{query_conditions[:text].mb_chars.downcase.to_s}%",
                      "%#{query_conditions[:text].mb_chars.downcase.to_s}%",
                      "%#{query_conditions[:text].mb_chars.downcase.to_s}%",
                      "%#{query_conditions[:text].mb_chars.downcase.to_s}%",
                      "%#{query_conditions[:text].mb_chars.downcase.to_s}%")
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
          q = get_final_search_query(get_base_search_query(onlyPersonalFavourites)).find(ids);
        elsif query_conditions.has_key?("favourites")
          favourites = FavouriteActivity.
              group(:activity_id).
              count(:user_id)

          sorted = favourites.sort_by { |k, v| -v }

          ids = sorted.map { |item| item[0] }.take(query_conditions["favourites"].to_i)

          q = get_final_search_query(get_base_search_query(onlyPersonalFavourites).where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED).where(:activity_id => ids));
        else
          q = get_final_search_query(q)
        end
        @activityVersions = q;

        # Copy "query-only aggregates" to their more appropriate "model-only" counter-parts (since ratings and favourites are associated with the activity itself rather than a specific revision of the activity)
        @activityVersions.each do |v|
          v.activity.favourite_count = v.favourite_count
          v.activity.ratings_count = v.ratings_count
          v.activity.ratings_average = v.ratings_average
          v.activity.my_rating = v.my_rating
        end

        # Returning JSON (the default behaviour) is handed off to the default Rails view mechanism.
        # Returning XML is explicitly handled by ActiveRecord's to_xml method. The output is customized for "the client which calculates activity relationships".
        respond_to do |format|
          format.json
          format.xml {
            render xml: @activityVersions.to_xml(
                root: 'activity',
                camelize: false,
                dasherize: false,
                skip_types: true,
                only: [
                    :id,
                    :name,
                    :descr_material,
                    :descr_introduction,
                    :descr_main,
                    :descr_safety,
                    :descr_notes,
                    :age_min,
                    :age_max,
                    :participants_min,
                    :participants_max,
                    :time_min,
                    :time_max,
                    :featured,
                    :activity_id
                ],
                include: {
                    categories: {
                        only: [:id]
                    }
                }
            )
          }
        end
      end

      def get_base_search_query(onlyPersonalFavourites = false)
        select = 'activity_versions.*, r.ratings_count, r.ratings_average, f.favourite_count'
        q = ActivityVersion.
            joins("LEFT JOIN (#{ACTIVITY_RATINGS_STATS_SQL}) r ON activity_versions.activity_id = r.activity_id").
            joins("LEFT JOIN (#{ACTIVITY_FAVOURITES_STATS_SQL}) f ON activity_versions.activity_id = f.activity_id")
        if @userApiKey
          q = q.joins("LEFT JOIN ratings my_ratings ON activity_versions.activity_id = my_ratings.activity_id AND my_ratings.user_id = " + @userApiKey.user_id.to_s)
          select += ', my_ratings.rating my_rating'
        else
          select += ', null my_rating'
        end
        if @userApiKey && onlyPersonalFavourites
          q = q.joins("JOIN favourite_activities my_favs ON activity_versions.activity_id = my_favs.activity_id AND my_favs.user_id = " + @userApiKey.user_id.to_s)
        end
        q = q.select(select)
      end

      def get_final_search_query(q)
        if !@attrs.include?('categories') && !@attrs.include?('media_files') && !@attrs.include?('references') && !@attrs.include?('related')
          # Client doesn't want neither categories, media files, references nor relations.
          q = q.includes(:activity)
        elsif @attrs.include?('categories') && !@attrs.include?('media_files') && !@attrs.include?('references') && !@attrs.include?('related')
          # Client wants categories but not media files, references or relations.
          q = q.includes(:activity, :categories)
        else
          # Client gets all information, even if client does not need it.
          q = q.includes(
              :activity,
              :categories,
              :media_files,
              :references,

              # Include :activity => :activity_relations instead of :activity => :relations since the former avoids
              # loading the actual related activities and instead only loads the *association* table entries (not also
              # the *associated activity* table entries). This optimization is only possible because the view,
              # _activity_version.json.jbuilder, only returns "activity.activity_relations.related_activity_id" instead
              # of "activity.relations.id" (the former needs only the activity_relations table, the latter needs both
              # the activity_relations table and the activities table)
              :activity => :activity_relations
          )
        end
        q.order(:activity_id, :id)
      end

      def init_output_attr_lists
        allowed_activity_attrs = [
            'id',
            # ratings_count is a derived/calculated attribute and not something stored in a particular table column.
            'ratings_count',
            # ratings_average is a derived/calculated attribute and not something stored in a particular table column.
            'ratings_average',
            # favourite_count is a derived/calculated attribute and not something stored in a particular table column.
            'favourite_count',
            'my_rating',
            'updated_at',
            'created_at'
        ]

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
            'updated_at',
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
        elsif params.has_key?('attrs')
          @attrs = params[:attrs].split(',')
        else
          @attrs = allowed_activity_attrs + allowed_activity_version_attrs + ['categories', 'media_files', 'references', 'related']
        end

        @activity_attrs = @attrs.nil? ? allowed_activity_attrs : @attrs & allowed_activity_attrs
        @activity_version_attrs = @attrs.nil? ? allowed_activity_version_attrs : @attrs & allowed_activity_version_attrs
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
        respond_with @activity
      end

      def create
        @activity = Activity.new(status: Db::ActivityVersionStatus::PUBLISHED)
        @activity.user = @userApiKey.user

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
          file = MediaFile.new({:uri => uri})
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
        a = Activity.
            #joins(:activity_versions).
            #order("activities.id, activity_versions.id DESC").
            #where("activity_versions.status = ?", Db::ActivityVersionStatus::PUBLISHED).
            #includes(:activity_versions, activity_versions: [:references, :categories]).
            joins("LEFT JOIN (#{ACTIVITY_RATINGS_STATS_SQL}) r ON activities.id = r.activity_id").
            joins("LEFT JOIN (#{ACTIVITY_FAVOURITES_STATS_SQL}) f ON activities.id = f.activity_id")

        select = 'activities.*, r.ratings_count, r.ratings_average, f.favourite_count'
        if @userApiKey
          a = a.joins("LEFT JOIN ratings my_ratings ON activities.id = my_ratings.activity_id AND my_ratings.user_id = " + @userApiKey.user_id.to_s)
          select += ', my_ratings.rating my_rating'
        else
          select += ', null my_rating'
        end
        a = a.select(select).find(id)

        # Copy values from "simple result hash" to "proper result attributes", otherwise the public_send method (used in JSON templates) will not work.
        a.ratings_count = a['ratings_count']
        a.ratings_average = a['ratings_average']
        a.favourite_count = a['favourite_count']
        a.my_rating = a['my_rating']
        a
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
        params.permit(:name, :descr_introduction, :descr_main, :descr_material, :descr_notes, :descr_prepare, :descr_safety, :age_1, :age_2, :participants_1, :participants_2, :time_1, :time_2, :featured, :text, :random, :favourites, :categories, :ratings_count_min, :ratings_average_min, :my_favourites, :id)
      end
    end
  end
end
