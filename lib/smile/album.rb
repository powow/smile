  # Result
  #     STANDARD RESPONSE
  # 
  # array Albums
  # Album
  #   integer id
  #   string Key
  #   string Title
  #   struct Category
  #   string id
  #   string Name
  #   struct SubCategory
  #   string id
  #   string Name
  #
  #     HEAVY RESPONSE
  #   
  # array Albums
  # Album
  #   integer id
  #   string Key
  #   string Title
  #   struct Category
  #     string id
  #     string Name
  #   struct SubCategory
  #     string id
  #     string Name
  #   string Description
  #   string Keywords
  #   boolean Geography (owner)
  #   integer Position
  #   struct Hightlight (owner)
  #     string id
  #   integer ImageCount
  #   string LastUpdated
  #   boolean Header (owner, power & pro only)
  #   boolean Clean (owner)
  #   boolean EXIF (owner)
  #   boolean Filenames (owner)
  #   struct Template (owner)
  #     string id
  #   string SortMethod (owner)
  #   boolean SortDirection (owner)
  #   string Password (owner)
  #   string PasswordHint (owner)
  #   boolean Public (owner)
  #   boolean WorldSearchable (owner)
  #   boolean SmugSearchable (owner)
  #   boolean External (owner)
  #   boolean Protected (owner, power & pro only)
  #   boolean Watermarking (owner, pro only)
  #   struct Watermark (owner, pro only)
  #     string id
  #   boolean HideOwner (owner)
  #   boolean Larges (owner, pro only)
  #   boolean XLarges (owner, pro only)
  #   boolean X2Larges (owner)
  #   boolean X3Larges (owner)
  #   boolean Originals (owner)
  #   boolean CanRank (owner)
  #   boolean FriendEdit (owner)
  #   boolean FamilyEdit (owner)
  #   boolean Comments (owner)
  #   boolean Share (owner)
  #   boolean Printable (owner)
  #   int ColorCorrection (owner)
  #   boolean DefaultColor (owner, pro only)  deprecated
  #   integer ProofDays (owner, pro only)
  #   string Backprinting (owner, pro only)
  #   float UnsharpAmount (owner, power & pro only)
  #   float UnsharpRadius (owner, power & pro only)
  #   float UnsharpThreshold (owner, power & pro only)
  #   float UnsharpSigma (owner, power & pro only)
  #   struct Community (owner)
  #     string id
#  
#  Created by Zac Kleinpeter on 2009-04-28.
#  Copyright 2009 Cajun Country. All rights reserved.
# 
class Smile::Album < Smile::Base

  class << self
    def from_json( json, session_id )
      result = JSON.parse( json )
      result["Albums"].map do |album_upcase|
        album = upper_hash_to_lower_hash( album_upcase )
        
        album.merge!( :album_id => album["id"] )
        
        a = Smile::Album.new( album )
        a.session_id = session_id
        a
      end
    end
    
    # This will pull a single album from the smugmug
    #
    # * SessionID - string. ( by default if logged in)
    # * AlbumID - string.
    # * Password - string (optional).
    # * SitePassword - string (optional).
    # * AlbumKey - string.
    # 
    def find( options={} )
      params = default_params.merge(
          :method => 'smugmug.albums.getInfo'
      )
      
      options = Smile::ParamConverter.clean_hash_keys( options )
      params.merge!( options ) if( options )
      
      json = RestClient.post Smile::Base::BASE, params
      
      album_upper = JSON.parse(json)
    
      album = upper_hash_to_lower_hash( album_upper['Album'] )
      album.merge!( :album_id => album["id"] )
      
      a = Smile::Album.new( album )
      a.session_id = session_id
      a
    end
    
    # Update the album from the following params
    #
    # @param [String] title What you want to call it
    # @param [optional, Hash] options wow it's a hash
    #
    # Essentials
    # @option options [Fixnum] :category_id it is what it is
    # @option options [optional, Fixnum] :sub_category_id ( 0 ) guess what this is
    # @option options [optional, String] :description what am i looking at
    # @option options [optional, String] :keywords space seperated or comman don't know
    # @option options [optional, Fixnum] :album_template_id ( 1 ) yup
    # @option options [optional, Boolean] :geography ( 0 ) huh?
    # @option options [optional, Fixnum] :highlight_id you guess is as good as mine
    # @option options [optional, Fixnum] :position I'm just the dev
    #
    # Look & Feel
    # @option options [optional, Boolean] :header ( 0 ) yup
    # @option options [optional, Boolean] :clean ( 0 ) @see http://smugmug.com
    # @option options [optional, Boolean] :exif ( 1 ) @see http://smugmug.com
    # @option options [optional, Boolean] :filenames ( 0 ) show file names
    # @option options [optional, Boolean] :square_thumbs ( 1 ) user square ones
    # @option options [optional, Fixnum] :template_id ( 0 ) 0:Viewer Choice 3:SmugMug 4:Traditional 7:All Thumbs 8:Slideshow 9:Journal 10:SmugMug Small 11:Filmstrip
    # @option options [optional, String] :sort_method ( 'Position' ) %w( Position Caption FileName Date DateTime DateTimeOriginal )
    # @option options [optional, 1 or 0] :sort_direction 0: Ascending (1-99, A-Z, 1980-2004, etc) 1: Descending (99-1, Z-A, 2004-1980, etc)
    #
    # Security & Privacy
    # @option options [optional, String] :password want one?
    # @option options [optional, String] :password_hint need one?
    # @option options [optional, Boolean] :public ( 1 ) is it?
    # @option options [optional, Boolean] :world_searchable ( 1 ) can i?
    # @option options [optional, Boolean] :smug_searchable ( 1 ) please?
    # @option options [optional, Boolean] :external ( 1 ) let everyone know
    # @option options [optional, Boolean] :protected ( 0 ) MINE!!!
    # @option options [optional, Boolean] :watermarking ( 0 ) kinda cool
    # @option options [optional, Fixnum] :watermark_id ( 0 ) which one
    # @option options [optional, Boolean] :hide_owner ( 0 ) you can't see me
    # @option options [optional, Boolean] :larges ( 1 ) show bigens
    # @option options [optional, Boolean] :x_larges ( 1 ) show X bigens
    # @option options [optional, Boolean] :x2_larges ( 1 ) show XX bigens
    # @option options [optional, Boolean] :x3_larges ( 1 ) show XXX bigens
    # @option options [optional, Boolean] :originals ( 1 ) show what i uploaded
    #
    # Social
    # @option options [optional, Boolean] :can_rank ( 1 ) well...yesss
    # @option options [optional, Boolean] :friend_edit ( 0 ) yeah i have friends!!!
    # @option options [optional, Boolean] :family_edit ( 0 ) go ahead ma
    # @option options [optional, Boolean] :comments ( 1 ) I just wanted to say....
    # @option options [optional, Boolean] :share ( 1 ) here you go
    #
    # Printing & Sales
    # @option options [optional, Boolean] :printable ( 1 ) yes
    # @option options [optional, Fixnum] :color_correction ( 2 ) 0:No 1:Yes 2:Injerit
    # @option options [optional, Boolean] :default_color ( 0 ) ( pro only deprecated ) 1:Auto 0: True
    # @option options [optional, Fixnum] :proof_days ( 0 ) yep ( pro only )
    # @option options [optional, String] :back_printing what you want to see behind you
    #
    # Photo Sharpening
    # @option options [optional, Float] :unsharp_amount ( 0.200 ) numbers
    # @option options [optional, Float] :unsharp_radius ( 1.000 ) more numbers
    # @option options [optional, Float] :unsharp_threshold ( 0.050 ) I'm a dev what does this mean?
    # @option options [optional, Float] :unsharp_sigma ( 1.000 ) and more numbers
    #
    # Community
    # @option options [optional, Fixnum] :community_id ( 0 ) join the group
    def create( title, options )
      params = default_params.merge(
          :method => 'smugmug.albums.create',
          :AlbumID => album_id
      )
      options = Smile::ParamConverter.clean_hash_keys( options )
      params.merge!( options ) if( options )

      json = RestClient.post BASE, params
      json = JSON.parse( json )
      raise json["message"] if json["stat"] == 'fail'
      find( :album_id => json["Album"]["id"], :album_key => json["Album"]["key"] )
      true
    end
  end

  # Update the album from the following params
  #
  # @param [optional, Hash] options wow it's a hash
  #
  # Essentials
  # @option options [optional, String] :title the title maybe?
  # @option options [optional, Fixnum] :category_id it is what it is
  # @option options [optional, Fixnum] :sub_category_id guess what this is
  # @option options [optional, String] :description what am i looking at
  # @option options [optional, String] :keywords space seperated or comman don't know
  # @option options [optional, Fixnum] :album_template_id yup
  # @option options [optional, Boolean] :geography huh?
  # @option options [optional, Fixnum] :highlight_id you guess is as good as mine
  # @option options [optional, Fixnum] :position I'm just the dev
  #
  # Look & Feel
  # @option options [optional, Boolean] :header yup
  # @option options [optional, Boolean] :clean @see http://smugmug.com
  # @option options [optional, Boolean] :exif @see http://smugmug.com
  # @option options [optional, Boolean] :filenames show file names
  # @option options [optional, Boolean] :square_thumbs user square ones
  # @option options [optional, Fixnum] :template_id 0:Viewer Choice 3:SmugMug 4:Traditional 7:All Thumbs 8:Slideshow 9:Journal 10:SmugMug Small 11:Filmstrip
  # @option options [optional, String] :sort_method %w( Position Caption FileName Date DateTime DateTimeOriginal )
  # @option options [optional, 1 or 0] :sort_direction 0: Ascending (1-99, A-Z, 1980-2004, etc) 1: Descending (99-1, Z-A, 2004-1980, etc)
  #
  # Security & Privacy
  # @option options [optional, String] :password want one?
  # @option options [optional, String] :password_hint need one?
  # @option options [optional, Boolean] :public is it?
  # @option options [optional, Boolean] :world_searchable can i?
  # @option options [optional, Boolean] :smug_searchable please?
  # @option options [optional, Boolean] :external let everyone know
  # @option options [optional, Boolean] :protected MINE!!!
  # @option options [optional, Boolean] :watermarking kinda cool
  # @option options [optional, Fixnum] :watermark_id which one
  # @option options [optional, Boolean] :hide_owner you can't see me
  # @option options [optional, Boolean] :larges show bigens
  # @option options [optional, Boolean] :x_larges show X bigens
  # @option options [optional, Boolean] :x2_larges show XX bigens
  # @option options [optional, Boolean] :x3_larges show XXX bigens
  # @option options [optional, Boolean] :originals show what i uploaded
  #
  # Social
  # @option options [optional, Boolean] :can_rank well...yesss
  # @option options [optional, Boolean] :friend_edit yeah i have friends!!!
  # @option options [optional, Boolean] :family_edit go ahead ma
  # @option options [optional, Boolean] :comments I just wanted to say....
  # @option options [optional, Boolean] :share here you go
  #
  # Printing & Sales
  # @option options [optional, Boolean] :printable yes
  # @option options [optional, Fixnum] :color_correction 0:No 1:Yes 2:Injerit
  # @option options [optional, Boolean] :default_color ( pro only deprecated ) 1:Auto 0: True
  # @option options [optional, Fixnum] :proof_days yep ( pro only )
  # @option options [optional, String] :back_printing what you want to see behind you
  #
  # Photo Sharpening
  # @option options [optional, Float] :unsharp_amount numbers
  # @option options [optional, Float] :unsharp_radius more numbers
  # @option options [optional, Float] :unsharp_threshold I'm a dev what does this mean?
  # @option options [optional, Float] :unsharp_sigma and more numbers
  #
  # Community
  # @option options [optional, Fixnum] :community_id join the group
  def update( options )
    params = default_params.merge(
        :method => 'smugmug.albums.changeSettings',
        :AlbumID => album_id
    )
    options = Smile::ParamConverter.clean_hash_keys( options )
    params.merge!( options ) if( options )
    
    json = RestClient.post BASE, params
    json = JSON.parse( json )
    raise json["message"] if json["stat"] == 'fail'
    true
  end
  
  # This will pull all the photos for a given album
  # * SessionID - string. ( by default if logged in)
  # * AlbumID - integer.
  # * Heavy - boolean (optional).
  # * Password - string (optional).
  # * SitePassword - string (optional).
  # * AlbumKey - string.
  def photos( options=nil )
    params = default_params.merge(
        :method => 'smugmug.images.get',
        :AlbumID => album_id,
        :AlbumKey => key,
        :Heavy => 1
    )
    options = Smile::ParamConverter.clean_hash_keys( options )
    params.merge!( options ) if( options )
    
    json = RestClient.post BASE, params

    Smile::Photo.from_json( json, session_id )
  end
  
  # Pull stats for an Album for a given Month and Year
  #
  #
  # @param [optional, Hash] options wow it's a hash
  # @option options [optional, Fixnum] :month (Date.today.month) month field
  # @option options [optional, Fixnum] :year (Date.today.year) the year and stuff
  # @option options [optional, 1 or 0] :heavy more details
  def stats( options =nil )
    params = default_params.merge( 
      :method => 'smugmug.albums.getStats',
      :AlbumID => album_id,
      :month => Date.today.month,
      :year => Date.today.year
    )
    options = Smile::ParamConverter.clean_hash_keys( options )
    
    params.merge!( options ) if( options )
    
    json = RestClient.post Smile::Base::BASE, params
    
    json = JSON.parse( json )
    raise json["message"] if json["stat"] == 'fail'

    stat = upper_hash_to_lower_hash( json['Album'] )
    OpenStruct.new( stat )
  end
  
  # Add an image or vid to the existing album
  # 
  # @param [String] image path to image
  # @param [options,Hash] options Extra params that are accepted 
  # @option options [optional, String] :caption For multi-line captions, use a carriage return between lines
  # @option options [optional, String] :keywords Sets the Keywords on the image
  # @option options [optional, Decimal] :latitude Sets the Latitude of the image (in the form D.d, such as 37.430096)
  # @option options [optional, Decimal] :longitude Sets the Longitude of the image (in the form D.d, such as -122.152269)
  # @option options [optional, Decimal] :altitude Sets the Altitude of the image (in meters)
  def add( image, options={} )
    if( File.exists?( image ) )
      options = Smile::ParamConverter.clean_hash_keys( options )
      json = RestClient.put UPLOAD + "/#{image}", File.read( image ),
        :content_length => File.size( image ),
        :content_md5 => MD5.hexdigest( File.read( image ) ),
        :x_smug_sessionid => session_id,
        :x_smug_version => VERSION,
        :x_smug_responseType => "JSON",
        :x_smug_albumid => album_id,
        :x_smug_filename => File.basename( image ),
        :x_smug_caption => options[:caption],
        :x_smug_keywords => options[:keywords],
        :x_smug_latitude => options[:latitude],
        :x_smug_longitude => options[:longitude],
        :x_smug_altitude => options[:altitude]
      
      image = JSON.parse( json )
      if( image && image["Image"] && image["Image"]["id"] )
        Smile::Photo.find( :image_id => image["Image"]["id"] )
      else
        raise Exception.new( "Failed to upload #{image}" )
      end
    else
      raise Exception.new( "Cannot find file #{image}." )
    end
  end
  
  # This method will re-sort all the photos inside of the album specified by 
  # AlbumID. Note that this is a one-time event, 
  # and doesn't apply directly to images added in the future by other means.
  def delete!
    params = default_params.merge( 
      :method => 'smugmug.albums.delete',
      :AlbumID => album_id
    )
    
    options = Smile::ParamConverter.clean_hash_keys( options )
    
    params.merge!( options ) if( options )
    
    json = RestClient.post Smile::Base::BASE, params
    
    json = JSON.parse( json )
    raise json["message"] if json["stat"] == 'fail'
    
    album_id = nil
    album_key = nil
    nil
  end
  
  
  def resort!( options =nil )
    params = default_params.merge( 
      :method => 'smugmug.albums.reSort',
      :AlbumID => album_id
    )
    
    json = RestClient.post Smile::Base::BASE, params
    
    json = JSON.parse( json )
    raise json["message"] if json["stat"] == 'fail'
    
    album_id = nil
    album_key = nil
    nil
  end
  
#  def category
#    ['category']
#  end
end
