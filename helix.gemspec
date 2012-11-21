require "rake"

spec = Gem::Specification.new do |s|
  s.name        = "helix"
  s.version     = "0.0.0.pre"
  s.summary     = "Wrapper library for the video API"
  s.description = "Provides helper libraries for Ruby access to the Twistage API"
  s.authors     = ["Twistage, Inc"]
  s.email       = "kbaird@twistage.com"
  s.files       = FileList["lib/helix.rb", "lib/helix/*.rb", "spec/**.rb", "LICENSE", "README.md"]
  s.has_rdoc    = true
  s.platform    = Gem::Platform::RUBY
  s.license     = "3-Clause BSD"
  s.homepage    = 'https://github.com/Twistage/helix/'
  s.add_dependency "json", ">= 1.5.4"
  s.add_dependency "rest-client", ">= 1.6.7"
  s.add_dependency "activesupport", ">= 3.0.9"
end

