# frozen_string_literal: true

module PlatformosCheck
  module LanguageServer
    module VariableLookupFinder
      module TolerantParser
        class Template
          class << self
            def parse(content)
              ##
              # The tolerant parser relies on a tolerant custom parse
              # context to creates a new 'Template' object, even when
              # a block is not closed.
              Liquid::Template.parse(content, environment: environment)
            end

            private

            def environment
              @environment ||= Liquid::Environment.build(tags: Liquid::Environment.default.tags.merge(
                {
                  'case' => Tags::TolerantCase,
                  'for' => Tags::TolerantFor,
                  'if' => Tags::TolerantIf,
                  'tablerow' => Tags::TolerantTableRow,
                  'unless' => Tags::TolerantUnless
                }
              ))
            end
          end
        end

        class Tags
          module TolerantBlockBody
            ##
            # This module defines the tolerant parse body that doesn't
            # raise syntax errors when a block is not closed. Thus, the
            # tolerant parser can build the AST for templates with this
            # kind of error, which is quite common in language servers.
            def parse_body(body, tokens)
              super
            rescue StandardError
              false
            end
          end

          class TolerantCase < Liquid::Case
            include TolerantBlockBody
          end

          class TolerantFor < Liquid::For
            include TolerantBlockBody
          end

          class TolerantIf < Liquid::If
            include TolerantBlockBody
          end

          class TolerantTableRow < Liquid::TableRow
            include TolerantBlockBody
          end

          class TolerantUnless < Liquid::Unless
            include TolerantBlockBody
          end
        end
      end
    end
  end
end
