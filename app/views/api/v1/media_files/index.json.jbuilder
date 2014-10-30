files ||= @media_files

json.array! files do |media_file|
  json.partial! media_file
end