# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_base_app_session',
  :secret      => '97a7f47b05c3264923c745e2a0488e36f610ba63e1a12ea3c8784fb9620bbf0eaf841dd3b0ff4891c5ffb027a82416aa2e26d1b1046f983e8c67e4b67eae16fa'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
