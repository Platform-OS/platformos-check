require 'platformos_check'

status_code = PlatformosCheck::LanguageServer.start
exit! status_code
