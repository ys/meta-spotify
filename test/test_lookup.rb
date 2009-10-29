require 'helper'

class TestLookup < Test::Unit::TestCase
  context "a new lookup" do
    should "create a new lookup object" do
      l = MetaSpotify::Lookup.new(TRACK_URI)
      assert_kind_of MetaSpotify::Lookup, l
      assert_equal TRACK_URI, l.uri
    end
    should "not create a lookup object without a proper spotify uri" do
      assert_raises MetaSpotify::URIError do
        MetaSpotify::Lookup.new('blah')
      end
    end
  end
  
  context "looking up an artist" do
    setup do
      FakeWeb.register_uri(:get,
                           "http://ws.spotify.com/lookup/1/?uri=#{CGI.escape ARTIST_URI}",
                           :body => fixture_file("artist.xml"))
      @lookup = MetaSpotify::Lookup.new(ARTIST_URI)
      @result = @lookup.fetch
    end
    should "fetch an artist and return an artist object" do
      assert_kind_of MetaSpotify::Artist, @result
      assert_equal "Basement Jaxx", @result.name
    end
  end
  
  context "looking up a album" do
    setup do
      FakeWeb.register_uri(:get,
                           "http://ws.spotify.com/lookup/1/?uri=#{CGI.escape ALBUM_URI}",
                           :body => fixture_file("album.xml"))
      @lookup = MetaSpotify::Lookup.new(ALBUM_URI)
      @result = @lookup.fetch
    end
    should "fetch an album and return an album object" do
      assert_kind_of MetaSpotify::Album, @result
      assert_equal "Remedy", @result.name
      assert_equal "1999", @result.released
    end
    should "create an artist object for that album" do
      assert_kind_of MetaSpotify::Artist, @result.artist
      assert_equal "Basement Jaxx", @result.artist.name
      assert_equal "spotify:artist:4YrKBkKSVeqDamzBPWVnSJ", @result.artist.uri
    end
  end
  
  context "looking up a track" do
    setup do
      FakeWeb.register_uri(:get,
                           "http://ws.spotify.com/lookup/1/?uri=#{CGI.escape TRACK_URI}",
                           :body => fixture_file("track.xml"))
      @lookup = MetaSpotify::Lookup.new(TRACK_URI)
      @result = @lookup.fetch
    end
    should "fetch a track and return a track object" do
      assert_kind_of MetaSpotify::Track, @result
      assert_equal "Rendez-vu", @result.name
      assert_equal 1, @result.track_number
      assert_equal 345, @result.length
      assert_equal 0.51368, @result.popularity
    end
    should "create an album object for that track" do
      assert_kind_of MetaSpotify::Album, @result.album
      assert_equal "Remedy", @result.album.name
      assert_equal "spotify:album:6G9fHYDCoyEErUkHrFYfs4", @result.album.uri
    end
    should "create an artist object for that album" do
      assert_kind_of MetaSpotify::Artist, @result.artist
      assert_equal "Basement Jaxx", @result.artist.name
      assert_equal "spotify:artist:4YrKBkKSVeqDamzBPWVnSJ", @result.artist.uri
    end
  end
end