source 'https://rubygems.org'

gem 'rails', '~> 6.1.0'

gem 'puma'

gem 'rake'
gem 'sdoc'
gem 'rspec-rails'
gem 'jbuilder'
gem 'kaminari'

gem 'ransack', '~> 2.6'
gem 'pagy', '~> 5.10'
gem 'slim', '~> 4.1'
gem 'pundit', '~> 2.2'
gem 'breadcrumbs_on_rails', '~> 4.1'

gem 'sass-rails'
gem 'turbolinks'

gem 'bootsnap', '>= 1.4.2', require: false

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  gem 'web-console'
  gem 'listen'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'spring'
  gem 'spring-watcher-listen'
end

gem 'simplecov', require: false
gem 'byebug', platforms: [:mri]

# platform specific gems

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'jdbc-sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter'
  gem 'jruby-openssl'
end
