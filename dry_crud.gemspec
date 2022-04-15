# encoding: UTF-8
require 'rubygems'
require 'date'

DRY_CRUD_GEMSPEC = Gem::Specification.new do |spec|
  spec.name    = 'dry_crud'
  spec.version = File.read('VERSION').strip
  spec.date    = Date.today.to_s

  spec.author   = 'Pascal Zumkehr'
  spec.email    = 'spam@codez.ch'
  spec.homepage = 'http://github.com/codez/dry_crud'

  spec.summary = <<-END
Generates DRY and specifically extendable CRUD controller, views and helpers
for Rails applications.
END
  spec.description = <<-END
Generates simple and extendable controller, views and helpers that support you
to DRY up the CRUD code in your Rails project. Start with these elements and
build a clean base to efficiently develop your application upon.
END

  spec.add_dependency 'rails', '>= 6.0'
  spec.add_dependency 'slim', '~> 4.1'
  spec.add_dependency 'pagy', '~> 5.10'
  spec.add_dependency 'pundit', '~> 2.2'

  files = Dir.glob('*').to_a
  readmes = files - files.grep(/(^|[^.a-z])[a-z]+/) - ['TODO']

  spec.files = Dir.glob('app/**/*').to_a +
    Dir.glob('config/**/*').to_a +
    Dir.glob('lib/**/*').to_a +
    readmes

  spec.extra_rdoc_files = readmes
  spec.rdoc_options << '--title' << '"Dry Crud"' <<
                       '--main' << 'README.rdoc' <<
                       '--line-numbers'
end
