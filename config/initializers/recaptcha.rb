Recaptcha.configure do |config|
  config.public_key  = AppConfig['captcha_public_key']
  config.private_key = AppConfig['captcha_private_key']
  config.handle_timeouts_gracefully = false
  config.skip_verify_env << 'development'
  #config.proxy = 'http://myproxy.com.au:8080'
end
