# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# JL added for fonts by recomendation (http://stackoverflow.com/questions/10905905/using-fonts-with-rails-asset-pipeline)
Rails.application.config.assets.precompile << /\.(?:svg|eot|woff|ttf)\z/

# JL added for datebox at request of rails error in browser
Rails.application.config.assets.precompile += %w( jqm-datebox.js )
Rails.application.config.assets.precompile += %w( jqm-datebox.mode.calbox.js )
Rails.application.config.assets.precompile += %w( jquery.mobile.datebox.i18n.en_US.utf8.js )