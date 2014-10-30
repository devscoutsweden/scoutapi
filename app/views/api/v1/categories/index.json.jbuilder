categories ||= @categories

json.array! categories do |category|
  json.partial! category
end