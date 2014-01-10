require 'tempfile'
module SimpleCaptcha #:nodoc
  module ImageHelpers #:nodoc

    mattr_accessor :image_styles
    @@image_styles = {
      'simply_red'   => ['-alpha set', '-fill darkred', '-background white', '-size 200x50', 'xc:white'],
      'simply_green' => ['-alpha set', '-fill darkgreen', '-background white', '-size 200x50', 'xc:white'],
      'simply_blue'  => ['-alpha set', '-fill darkblue', '-background white', '-size 200x50', 'xc:white'],
      'red'          => ['-alpha set', '-fill \#A5A5A5', '-background \#800E19', '-size 245x60', 'xc:\#800E19'],
    }

    DISTORTIONS = ['low', 'medium', 'high']

    class << self

      def image_params(key = 'simply_blue')
        image_keys = @@image_styles.keys

        style = begin
          if key == 'random'
            image_keys[rand(image_keys.length)]
          else
            image_keys.include?(key) ? key : 'simply_blue'
          end
        end

        @@image_styles[style]
      end

      def image_params_from_color(color)
        ["-alpha set -background none -fill \"#{color}\""]
      end

      def distortion(key='low')
        key =
          key == 'random' ?
          DISTORTIONS[rand(DISTORTIONS.length)] :
          DISTORTIONS.include?(key) ? key : 'low'
        case key.to_s
          when 'low' then return [0 + rand(2), 80 + rand(20)]
          when 'medium' then return [2 + rand(2), 50 + rand(20)]
          when 'high' then return [4 + rand(2), 30 + rand(20)]
        end
      end
    end

    if RUBY_VERSION < '1.9'
      class Tempfile < ::Tempfile
        # Replaces Tempfile's +make_tmpname+ with one that honors file extensions.
        def make_tmpname(basename, n = 0)
          extension = File.extname(basename)
          sprintf("%s,%d,%d%s", File.basename(basename, extension), $$, n, extension)
        end
      end
    end

    private

      def generate_simple_captcha_image(simple_captcha_key) #:nodoc
        amplitude, frequency = ImageHelpers.distortion(SimpleCaptcha.distortion)
        text = Utils::simple_captcha_new_value(simple_captcha_key)
        if SimpleCaptcha.image_color.nil?
          params = ImageHelpers.image_params(SimpleCaptcha.image_style).dup
        else
          params = ImageHelpers.image_params_from_color(SimpleCaptcha.image_color).dup
          params << "-size #{SimpleCaptcha.image_size} xc:transparent"
        end
        params << "-gravity \"Center\""

        psz = SimpleCaptcha.pointsize
        if params.join(' ').index('-pointsize').nil?
          params << "-pointsize #{psz}"
        end

        dst = Tempfile.new(RUBY_VERSION < '1.9' ? 'simple_captcha.png' : ['simple_captcha', '.png'], SimpleCaptcha.tmp_path)
        dst.binmode
        text.split(//).each_with_index do |letter, index|
          i = -(2  * psz) + (index * 0.7 * psz) + rand(-3..3)
          params << "-draw \"translate #{i},#{rand(-3..3)} skewX #{rand(-15..15)} gravity center text 0,0 '#{letter}'\" "
        end

        params << "-wave #{amplitude}x#{frequency}"

        unless params.join(' ').index('-size').nil?
          size = params.join(' ').match '-size (\d+)x(\d+)'
          (1..SimpleCaptcha.wave_count).each do |i|
            params << "-draw \"polyline #{rand(size[1].to_i)},#{rand(size[2].to_i)} #{rand(size[1].to_i)},#{rand(size[2].to_i)}\""
          end
        end

        params << "\"#{File.expand_path(dst.path)}\""

        SimpleCaptcha::Utils::run("convert", params.join(' '))

        dst.close

        File.expand_path(dst.path)
      end
  end
end
