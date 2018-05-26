module SimpleCaptcha
  class SimpleCaptchaData
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: "simple_captcha_data"

    field :key, :type => String
    field :value, :type => String

    class << self
      def get_data(key)
        SimpleCaptchaData.where(:key => key).first || new(:key => key)
      end

      def remove_data(key)
        SimpleCaptchaData.where(:key => key).first.delete
        clear_old_data(1.hour.ago)
      end

      def clear_old_data(time = 1.hour.ago)
        return unless Time === time
        SimpleCaptchaData.where(:updated_at.lt => time.utc).delete_all
      end
    end
  end
end
