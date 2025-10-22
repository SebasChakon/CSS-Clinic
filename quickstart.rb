require 'cloudinary'

if Cloudinary.config.api_key.blank?
  require './config'
end

puts 'My cloud name is:' + Cloudinary.config.cloud_name
## Upload two files using the Upload API:

# Use the uploaded filename as the asset's public ID + allow overwriting the asset with new versions.
upload1=Cloudinary::Uploader.upload("https://cloudinary-devs.github.io/cld-docs-assets/assets/images/model.jpg", 
    use_filename:true, 
    unique_filename:false,
    overwrite:true
    )

# Retrieve some attributes from the first upload response.

  puts "File size of the #{upload1['public_id']}.#{upload1['format']} #{upload1['resource_type']}: #{upload1['bytes']/1024} KB"     

# Manually set the asset's public ID + allow overwriting asset with new versions.

  upload2=Cloudinary::Uploader.upload("https://cloudinary-devs.github.io/cld-docs-assets/assets/images/coffee_cup.jpg", 
      public_id: "coffee", 
      unique_filename: false,
      overwrite: true
      )


# Retrieve some attributes from the second upload response.
  puts "File size of the #{upload2['public_id']}.#{upload2['format']} #{upload2['resource_type']}: #{upload2['bytes']/1024} KB"
## Manage existing assets using the Admin API

# Retrieve and print the details for a specific stored asset, 
# including the optional `faces` data, 
# based on the public ID returned in the previous upload.

my_asset = upload1['public_id']

puts %{
Asset details:
=================

}

jj details = Cloudinary::Api.resource(my_asset,
faces: true)

puts %{
================================

}

# Find out how many faces are in the image, and depending on result, tag the image accordingly.
facecount = details['faces'].count

puts "Number of faces in this image: #{facecount}"  

if facecount > 0
  asset_update=Cloudinary::Api.update(my_asset,
  tags: "people")
else 
  asset_update=Cloudinary::Api.update(my_asset,
  tags: "products")
end

asset_tags = asset_update['tags']

puts "Asset tags: #{asset_tags}"

## Generate transformation URLs for previously uploaded assets.

my_asset1 = upload1['public_id']+'.jpg'
my_asset2 = upload2['public_id']+'.jpg'

# Scale and then crop the excess to 'fill' 640*200px banner-shape, focussed on the largest face (if any). 
puts Cloudinary::Utils.cloudinary_url(my_asset1, transformation: 
    {crop: "fill", gravity: "face", width: 640, height: 200,  }
  )

# Create a 200px square (1:1 aspect ratio) thumbnail, then round to a circle to get a profile photo of the face.
puts Cloudinary::Utils.cloudinary_url(my_asset1, transformation: [
    {crop: "thumb", gravity: "face",width: 200, aspect_ratio: "1.0"},
    {radius: "max"}
])

# Deliver a URL link to the original of the second image.
puts Cloudinary::Utils.cloudinary_url(my_asset2)

# Scale & crop to a portrait image (6:10 aspect ratio), apply a sepia effect, 
# and automatically optimize the image quality and file format to best balance 
# between visual quality and small file size.
puts Cloudinary::Utils.cloudinary_url(my_asset2, transformation: [
    {crop: "fill", aspect_ratio: "0.6", width: 400},
    {effect: "sepia"},
    {fetch_format: "auto"},
    {quality: "auto"}
    ])