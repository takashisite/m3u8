module M3u8
  # PlaylistItem represents a set of EXT-X-STREAM-INF attributes
  class PlaylistItem
    attr_accessor :program_id, :width, :height, :codecs, :bandwidth, :playlist,
                  :audio_codec, :level, :profile, :video, :audio,
                  :average_bandwidth, :subtitles, :closed_captions
    MISSING_CODEC_MESSAGE = 'Audio or video codec info should be provided.'

    def initialize(params = {})
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    def resolution
      return if width.nil?
      "#{width}x#{height}"
    end

    def codecs
      return @codecs unless @codecs.nil?

      video_codec = video_codec profile, level

      if video_codec.nil?
        return audio_codec
      else
        if audio_codec.nil?
          return video_codec
        else
          return "#{video_codec},#{audio_codec}"
        end
      end
    end

    def to_s
      validate

      attributes = [program_id_format,
                    resolution_format,
                    codecs_format,
                    bandwidth_format,
                    average_bandwidth_format,
                    audio_format,
                    video_format,
                    subtitles_format,
                    closed_captions_format].compact.join(',')
      "#EXT-X-STREAM-INF:#{attributes}\n#{playlist}"
    end

    private

    def validate
      fail MissingCodecError, MISSING_CODEC_MESSAGE if codecs.nil?
    end

    def program_id_format
      return if program_id.nil?
      "PROGRAM-ID=#{program_id}"
    end

    def resolution_format
      return if resolution.nil?
      "RESOLUTION=#{resolution}"
    end

    def codecs_format
      %(CODECS="#{codecs}")
    end

    def bandwidth_format
      "BANDWIDTH=#{bandwidth}"
    end

    def average_bandwidth_format
      return if average_bandwidth.nil?
      "AVERAGE-BANDWIDTH=#{average_bandwidth}"
    end

    def audio_format
      return if audio.nil?
      %(AUDIO="#{audio}")
    end

    def video_format
      return if video.nil?
      %(VIDEO="#{video}")
    end

    def subtitles_format
      return if subtitles.nil?
      %(SUBTITLES="#{subtitles}")
    end

    def closed_captions_format
      return if closed_captions.nil?
      %(CLOSED-CAPTIONS="#{closed_captions}")
    end

    def audio_codec
      return if @audio_codec.nil?
      return 'mp4a.40.2' if @audio_codec.downcase == 'aac-lc'
      return 'mp4a.40.5' if @audio_codec.downcase == 'he-aac'
      return 'mp4a.40.34' if @audio_codec.downcase == 'mp3'
    end

    def video_codec(profile, level)
      return if profile.nil? || level.nil?

      profile = profile.downcase
      return 'avc1.66.30' if profile == 'baseline' && level == 3.0
      return 'avc1.42001f' if profile == 'baseline' && level == 3.1
      return 'avc1.77.30' if profile == 'main' && level == 3.0
      return 'avc1.4d001f' if profile == 'main' && level == 3.1
      return 'avc1.4d0028' if profile == 'main' && level == 4.0
      return 'avc1.64001f' if profile == 'high' && level == 3.1
      return 'avc1.640028' if profile == 'high' &&
                              (level == 4.0 || level == 4.1)
    end
  end
end
