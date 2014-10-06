require 'spec_helper'

describe M3u8::Playlist do
  it 'should generate codecs string' do

    codecs = M3u8::Playlist.codecs
    expect(codecs).to be_nil

    codecs = M3u8::Playlist.codecs({ :audio => 'aac-lc' })
    expect(codecs).to eq 'mp4a.40.2'

    codecs = M3u8::Playlist.codecs({ :audio => 'AAC-LC' })
    expect(codecs).to eq 'mp4a.40.2'

    codecs = M3u8::Playlist.codecs({ :audio => 'he-aac' })
    expect(codecs).to eq 'mp4a.40.5'

    codecs = M3u8::Playlist.codecs({ :audio => 'HE-AAC' })
    expect(codecs).to eq 'mp4a.40.5'

    codecs = M3u8::Playlist.codecs({ :audio => 'he-acc1' })
    expect(codecs).to be_nil

    codecs = M3u8::Playlist.codecs({ :audio => 'mp3' })
    expect(codecs).to eq 'mp4a.40.34'

    codecs = M3u8::Playlist.codecs({ :audio => 'MP3' })
    expect(codecs).to eq 'mp4a.40.34'

    options = { :profile => 'baseline', :level => 3.0 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.66.30'

    options = { :profile => 'baseline', :level => 3.0, :audio => 'aac-lc' }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.66.30,mp4a.40.2'

    options = { :profile => 'baseline', :level => 3.0, :audio => 'mp3' }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.66.30,mp4a.40.34'

    options = { :profile => 'baseline', :level => 3.1 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.42001f'

    options = { :profile => 'baseline', :level => 3.1, :audio => 'he-aac' }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.42001f,mp4a.40.5'

    options = { :profile => 'main', :level => 3.0 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.77.30'

    options = { :profile => 'main', :level => 3.0, :audio => 'aac-lc' }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.77.30,mp4a.40.2'

    options = { :profile => 'main', :level => 3.1 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.4d001f'

    options = { :profile => 'main', :level => 4.0 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.4d0028'

    options = { :profile => 'high', :level => 3.1 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.64001f'

    options = { :profile => 'high', :level => 4.0 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.640028'

    options = { :profile => 'high', :level => 4.1 }
    codecs = M3u8::Playlist.codecs options
    expect(codecs).to eq 'avc1.640028'
  end

  it 'should render master playlist' do
    playlist = M3u8::Playlist.new
    playlist.add_playlist '1', 'playlist_url', 6400, { :audio => 'mp3' }

    output = "#EXTM3U\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=1,CODECS=""mp4a.40.34"",BANDWIDTH=6400\n" +
    "playlist_url\n"

    expect(playlist.to_s).to eq output

    playlist = M3u8::Playlist.new
    options = { :width => 1920, :height => 1080, :profile => 'high', :level => 4.1, :audio => 'aac-lc'}
    playlist.add_playlist '2', 'playlist_url', 50000, options

    output = "#EXTM3U\n" +
    "#EXT-X-STREAM-INF:PROGRAM-ID=2,RESOLUTION=1920x1080,CODECS=""avc1.640028,mp4a.40.2"",BANDWIDTH=50000\n" +
    "playlist_url\n"

    expect(playlist.to_s).to eq output
  end
end