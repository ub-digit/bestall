if Rails.env == 'test'
  secret_config = YAML.load_file("#{Rails.root}/config/config_secret.test.yml")
else
  secret_config = YAML.load_file("#{Rails.root}/config/config_secret.yml")
end
APP_CONFIG = secret_config
