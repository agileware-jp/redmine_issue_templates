# commonmarker < 2.6 requires RubyGems ~> 3.4, so bundle install fails on RubyGems 4.
# Redmine's Gemfile pins commonmarker ~> 2.3; replace it when running on RubyGems 4.
if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('4.0')
  dependencies.reject! { |i| i.name == 'commonmarker' }
  gem 'commonmarker', '~> 2.6'
end

group :test do
  gem 'simplecov-rcov', require: false
  gem 'rspec-rails'
  if RUBY_VERSION < '3.0'
    # factory_bot 6.4.5以上はRuby3.0が必要なため、それ以下のバージョンでは6.4.5未満にする
    # https://github.com/thoughtbot/factory_bot/releases/tag/v6.4.5
    gem 'factory_bot', '<6.4.5'
  end
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'database_cleaner'
  dependencies.reject! { |i| i.name == 'nokogiri' } # Ensure Nokogiri have new version
end

# for Debug
group :development, :test do
  gem 'pry-rails'
  gem 'pry-byebug'
end
