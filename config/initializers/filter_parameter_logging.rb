# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  passw secret token _key -key crypt salt certificate otp ssn authorization basic_auth cookie sid
]
