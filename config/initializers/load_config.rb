require "erb"
require "yaml"

secret_config_file = Rails.env == 'test' ? 'config/config_secret.test.yml' : 'config/config_secret.yml'
yaml = Pathname.new("#{Rails.root}/#{secret_config_file}")
secret_config = YAML.load(ERB.new(yaml.read).result(binding))
locations = YAML.load_file("#{Rails.root}/config/data/locations.json")
APP_CONFIG = secret_config.merge(locations)
