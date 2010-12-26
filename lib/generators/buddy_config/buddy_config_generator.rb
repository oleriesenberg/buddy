class BuddyConfigGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def create_config
    template 'buddy.yml', File.join('config', "buddy.yml")
  end
end
