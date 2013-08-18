Recaptcha.configure do |config|
  config.public_key  = '6Lc7OOYSAAAAAMYrtJUBBrMHBMVF507AhW1xwdO9'
  config.private_key = '6Lc7OOYSAAAAABXxGkHG-AyiAjdzaodQijxcUTqa'
  config.handle_timeouts_gracefully = false
  config.skip_verify_env << "development"
  #config.proxy = 'http://myproxy.com.au:8080'
end
