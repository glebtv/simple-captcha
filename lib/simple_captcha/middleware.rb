# encoding: utf-8
module SimpleCaptcha
  class Middleware
    include SimpleCaptcha::ImageHelpers
    
    DEFAULT_SEND_FILE_OPTIONS = {
      :type         => 'application/octet-stream'.freeze,
      :disposition  => 'attachment'.freeze,
    }.freeze
    
    def initialize(app, options={})
      @app = app
      self
    end
    
    def call(env) # :nodoc:
      if env["REQUEST_METHOD"] == "GET" && captcha_path?(env['PATH_INFO'])
        make_image(env)
      else
        @app.call(env)
      end
    end
    
    protected
      def make_image(env, headers = {}, status = 404)
        request = Rack::Request.new(env)
        code = request.params["code"]
        body = []
        if !code.blank? && Utils::simple_captcha_value(code)
          return send_file(generate_simple_captcha_image(code), :type => 'image/jpeg', :disposition => 'inline', :filename =>  'simple_captcha.jpg')
        end
        
        [status, headers, body]
      end
      
      def captcha_path?(request_path)
        request_path.include?('/simple_captcha')
      end
      
      def send_file(path, options = {})
        unless File.file?(path) and File.readable?(path)
          puts "[simple captcha] Cannot read file #{path}"
          raise MissingFile, "Cannot read file #{path}"
        end

        options[:filename] ||= File.basename(path) unless options[:url_based_filename]

        status = options[:status] || 200
        headers = {
          "Content-Disposition" => "#{options[:disposition]}; filename='#{options[:filename]}'",
          # "Content-Type" => options[:type],
          'Content-Transfer-Encoding' => 'binary',
          'Cache-Control' => 'private'
        }
        response_body = [File.open(path, "rb").read]
        File.delete(path)
        
        [status, headers, response_body]
      end
  end
end
