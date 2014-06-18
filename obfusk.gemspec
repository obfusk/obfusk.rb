require File.expand_path('../lib/obfusk/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'obfusk'
  s.homepage    = 'https://github.com/obfusk/obfusk.rb'
  s.summary     = 'functional programming library for ruby'

  s.description = <<-END.gsub(/^ {4}/, '')
    functional programming library for ruby
  END

  s.version     = Obfusk::VERSION
  s.date        = Obfusk::DATE

  s.authors     = [ 'Felix C. Stegerman' ]
  s.email       = %w{ flx@obfusk.net }

  s.licenses    = %w{ LGPLv3+ }

  s.files       = %w{ .yardopts README.md Rakefile obfusk.gemspec } \
                + Dir['lib/**/*.rb']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov', '~> 0.7'  # TODO
  s.add_development_dependency 'yard'

  s.required_ruby_version = '>= 1.9.1'
end
