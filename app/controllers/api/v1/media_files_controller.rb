require 'net/http'
require 'rack/mime'

module Api
  module V1
    class MediaFilesController < ApplicationController
      before_filter :restrict_access_to_api_users, except: [:index, :show]
      before_action :set_media_file, only: [:show, :update, :destroy, :handle_resized_image_request]

      def index
        authorize MediaFile
        @media_files = MediaFile.all
        respond_with @media_files
      end

      def create
        authorize MediaFile
        @media_file = MediaFile.new(validated_params)

        base64_data = validated_params["data"]
        if !base64_data.nil?
          mime_type = validated_params['mime_type']

          saved_file_path = save_base64_encoded_file(base64_data, mime_type)

          @media_file.data = nil

          # Set uri attribute to the file's path as seen from the "outside", i.e. the path part of the file's URL.
          @media_file.uri = saved_file_path[Rails.root.join('public').to_s.length+1 .. -1]
        end

        if @media_file.save
          respond_with :api, :v1, @media_file, status: :created
        else
          respond_with @media_file.errors, status: :unprocessable_entity
        end
      end

      def save_base64_encoded_file(base64_data, mime_type)
        folder_name = sprintf("%04d", (MediaFile.maximum(:id)+1).round(-3)) # Create one folder for every 1000 uploads
        extension = Rack::Mime::MIME_TYPES.invert[mime_type]
        random_name = [*('a'..'z')].shuffle[0, 20].join

        folder_path = Rails.root.join('public', 'system', 'media_files', folder_name)

        Dir.mkdir(folder_path, 0777) unless File.exists?(folder_path)

        f = File.new("#{folder_path}/#{random_name}#{extension}", "w+b")
        f.write(Base64.decode64(base64_data))
        Rails.logger.info("Uploaded file saved as #{f.path}. Size: #{f.size} bytes.")
        f.close()

        f.path.to_s
      end

      def show
        authorize @media_file
        respond_with @media_file
      end

      def update
        authorize @media_file
        if @media_file.update(validated_params)
          head :no_content
        else
          respond_with @media_file.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @media_file
        if @media_file.destroy
          head :no_content
        else
          respond_with @media_file.errors, status: :internal_server_error
        end
      end

      def handle_resized_image_request
        skip_authorization
        begin
          size = params.require(:size)
          !!Float(size) # Will raise exception if parameter value is not numeric
          size = size.to_s.to_f # Convert parameter value to floating-point number
          if size < 1
            raise ArgumentError.new("Too small size")
          end
        rescue StandardError => e
          render_error e, "Invalid size", :unprocessable_entity
          return
        end

        if size > 100
          size = (size / 100).ceil * 100
        end

        Rails.logger.info("Will return #{@media_file.uri}, resized to #{size}x#{size} pixels.")

        local_name = Digest::MD5.hexdigest((size.nil? ? 'full' : size.to_s) + @media_file.uri) + File.extname(@media_file.uri)

        local_folder_path = 'tmp/media-file-cache'

        if !Dir.exists?(local_folder_path)
          Dir.mkdir(local_folder_path)
        end
        local_path = File.join(Pathname.new(local_folder_path).to_s, local_name)

        if !File.exists?(local_path)
          download_image_from_url(@media_file.uri, local_path)

          if !size.nil?
            cmd = "convert \"#{local_path}\" -resize \"#{size}x#{size}\" -strip"
            if @media_file.uri.end_with?('png')
              cmd += " -quality 95 -colors 255"
            end
            cmd += " \"#{local_path}\""
            Rails.logger.info("Local path: #{local_path}")
            Rails.logger.info("Resizing image by executing this command: #{cmd}")
            resp = system(cmd)
            if resp.nil? || !resp
              File.delete local_path
              render_error nil, "Could not convert image file", :internal_server_error
              return
            end
          end
        end

        redirect_to "/media-file-cache/" + local_name
      end

      private

      # Source: www.umair.io/how-to-download-images-from-url-in-ruby-and-rails/
      def download_image_from_url(url, local_path)
        uri = URI.parse(URI.escape(url))
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = url.include?('https')

        response = http.request(
            Net::HTTP::Get.new(uri.request_uri)
        )
        File.open(local_path, 'wb') { |f| f.write(response.body) }
        Rails.logger.info("Has downloaded #{url} and saved it as #{local_path}")
      end

      def find_media(id)
        MediaFile.find(id)
      end

      def set_media_file
        @media_file = find_media(params[:id] || params[:media_file_id])
      end

      def validated_params
        Rails.logger.info("PARAMS: #{params.inspect}")
        params.permit(:mime_type, :data, :uri, :status)
      end
    end
  end
end
