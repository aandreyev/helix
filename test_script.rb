require 'helix'

helix = Helix::Config.new()

media_by_id = {
  'album_id' => helix.album,
  'image_id' => helix.image,
  'track_id' => helix.track,
  'video_id' => helix.video
}
media_by_id.each do |guid_key,ref|

  klass = ref.class

  items = ref.find_all(query: 'rest-client', status: :complete)
  puts "Searching #{klass.to_s} on query => 'rest-client' returns #{items}"

  media_id = helix.credentials[guid_key]
  next if media_id.nil?
  item = ref.find(media_id)
  puts "Read #{klass.to_s} from guid #{media_id}: #{item.inspect}"

  if guid_key == 'video_id'
    h = {
      # these keys are only available on the oobox branch
      #comments:    item.comments,
      #ratings:     item.ratings,
      screenshots: item.screenshots,
    }
    puts "#{klass.to_s} #{media_id} has #{h}"
  end

  next if guid_key == 'album_id' # No Update API yet

  ['before rest-client', 'updated via rest-client' ].each do |desired_title|
    item.update(title: desired_title, description: "description of #{desired_title}")
    item.reload
    puts "#{klass.to_s} #{media_id} title is '#{item.title}'"
    puts "#{klass.to_s} #{media_id} description is '#{item.description}'"
  end
end
