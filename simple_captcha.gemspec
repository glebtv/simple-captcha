# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "simple_captcha/version"

Gem::Specification.new do |s|
  s.name = "glebtv-simple_captcha"
  s.version = SimpleCaptcha::VERSION.dup
  s.platform = Gem::Platform::RUBY
  s.summary = "A fork of a fork of a fork of simple_captcha."
  s.description = "."
  s.authors = ["GlebTv"]
  s.email = "glebtv@gmail.com"
  s.homepage = "http://github.com/glebtv/simple-captcha"

  s.files = Dir["{lib}/**/*"] + %w(Rakefile README.rdoc)
  s.test_files = Dir["{test}/**/*"]
  s.extra_rdoc_files = %w(README.rdoc)
  s.require_paths = %w(lib)

  s.add_development_dependency("activesupport", [">= 5.0"])
end
