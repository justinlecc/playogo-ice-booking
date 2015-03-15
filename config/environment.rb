# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Mailer
# config.action_mailer.raise_delivery_errors = true

ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.gmail.com',
  :domain         => 'mail.google.com',
  :port           => 587,
  :user_name      => 'playogosports@gmail.com',
  :password       => 'play4fun',
  :authentication => :plain,
  :enable_starttls_auto => true
}