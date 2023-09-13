# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    def self.partial_tag(tag)
      /
        \{%-?\s*#{tag}\s+'(?<partial>[^']*)'|
        \{%-?\s*#{tag}\s+"(?<partial>[^"]*)"|

        # in liquid tags the whole line is white space until the tag
        ^\s*#{tag}\s+'(?<partial>[^']*)'|
        ^\s*#{tag}\s+"(?<partial>[^"]*)"
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
    PARTIAL_INCLUDE = partial_tag('include')
    PARTIAL_INCLUDE_FORM = partial_tag('include_form')
    PARTIAL_FUNCTION = partial_tag_with_result('function')
    PARTIAL_GRAPHQL = partial_tag_with_result('graphql')
    PARTIAL_BACKGROUND = partial_tag_with_result('background')

    ASSET_INCLUDE = /
      \{\{-?\s*'(?<partial>[^']*)'\s*\|\s*asset_url|
      \{\{-?\s*"(?<partial>[^"]*)"\s*\|\s*asset_url|

      # in liquid tags the whole line is white space until the asset partial
      ^\s*(?:echo|assign[^=]*=)\s*'(?<partial>[^']*)'\s*\|\s*asset_url|
      ^\s*(?:echo|assign[^=]*=)\s*"(?<partial>[^"]*)"\s*\|\s*asset_url
    /mix
  end
end
