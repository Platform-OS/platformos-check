# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    def self.partial_tag(tag, with_rc: false)
      /
        \{%-?\s*#{tag}#{'(_rc)?' if with_rc}\s+'(?<partial>[^']*)'|
        \{%-?\s*#{tag}#{'(_rc)?' if with_rc}\s+"(?<partial>[^"]*)"|

        # in liquid tags the whole line is white space until the tag
        ^\s*#{tag}#{'(_rc)?' if with_rc}\s+'(?<partial>[^']*)'|
        ^\s*#{tag}#{'(_rc)?' if with_rc}\s+"(?<partial>[^"]*)"
      /mix
    end

    def self.partial_tag_with_result(tag)
      /
        \{%-?\s*#{tag}\s+(?<var>[\w]+)\s*=\s*'(?<partial>[^']*)'|
        \{%-?\s*#{tag}\s+(?<var>[\w]+)\s*=\s*"(?<partial>[^"]*)"|

        # in liquid tags the whole line is white space until the tag
        ^\s*#{tag}\s+(?<var>[\w]+)+\s*=\s*'(?<partial>[^']*)'|
        ^\s*#{tag}\s+(?<var>[\w]+)+\s*=\s*"(?<partial>[^"]*)"
      /mix
    end

    PARTIAL_RENDER = partial_tag('render')
    PARTIAL_THEME_RENDER = partial_tag('theme_render', with_rc: true)
    PARTIAL_INCLUDE = partial_tag('include')
    PARTIAL_INCLUDE_FORM = partial_tag('include_form')
    PARTIAL_FUNCTION = partial_tag_with_result('function')
    PARTIAL_GRAPHQL = partial_tag_with_result('graphql')
    PARTIAL_BACKGROUND = partial_tag_with_result('background')

    TAGS_FOR_FILTERS = 'echo|print|log|hash_assign|assign'
    TRANSLATION_FILTERS_NAMES = 'translate|t_escape|translate_escape|t[^\\w]'
    OPTIONAL_SCOPE_ARGUMENT = %((:?([\\w:'"\\s]*)\\s*(scope:\\s*['"](?<scope>[^'"]*)['"]))?)

    LOCALIZE_FILTERS_NAMES = ''

    ASSET_INCLUDE = /
      \{\{-?\s*'(?<partial>[^']*)'\s*\|\s*asset_url|
      \{\{-?\s*"(?<partial>[^"]*)"\s*\|\s*asset_url|

      # in liquid tags the whole line is white space until the asset partial
      ^\s*(?:#{TAGS_FOR_FILTERS}[^=]*=)\s*'(?<partial>[^']*)'\s*\|\s*asset_url|
      ^\s*(?:#{TAGS_FOR_FILTERS}[^=]*=)\s*"(?<partial>[^"]*)"\s*\|\s*asset_url
    /mix

    TRANSLATION_FILTER = /
      '(?<key>[^']*)'\s*\|\s*(#{TRANSLATION_FILTERS_NAMES})#{OPTIONAL_SCOPE_ARGUMENT}|
      "(?<key>[^"]*)"\s*\|\s*(#{TRANSLATION_FILTERS_NAMES})#{OPTIONAL_SCOPE_ARGUMENT}
    /mix

    LOCALIZE_FILTER = /
      [\s\w'"-:.]+\|\s*(localize|l):\s*'(?<key>[^']*)'|
      [\s\w'"-:.]+\|\s*(localize|l):\s*"(?<key>[^"]*)"
    /mix
  end
end
