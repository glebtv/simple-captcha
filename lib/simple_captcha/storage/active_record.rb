module SimpleCaptcha
  class SimpleCaptchaData < ::ActiveRecord::Base
    self.table_name = "simple_captcha_data"

    class << self
      def get_data(key)
        data = find_by_key(key) || new(:key => key)
      end

      def remove_data(key)
        where("#{connection.quote_column_name(:key)} = ?", key).delete_all
        clear_old_data(1.hour.ago)
      end

      def clear_old_data(time = 1.hour.ago)
        return unless Time === time
        where("#{connection.quote_column_name(:updated_at)} < ?", time).delete_all
      end
    end
  end
end
