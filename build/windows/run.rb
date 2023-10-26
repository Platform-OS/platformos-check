puts 'hello world'

require 'platformos_check'

status_code = PlatformosCheck::LanguageServer.start
puts status_code

exit! status_code
