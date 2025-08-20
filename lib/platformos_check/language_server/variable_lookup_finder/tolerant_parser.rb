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
                  'case' => Tags::Case,
                  'for' => Tags::For,
                  'if' => Tags::If,
                  'tablerow' => Tags::TableRow,
                  'unless' => Tags::Unless
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

          class Case < Liquid::Case
            include TolerantBlockBody
          end

          class For < Liquid::For
            include TolerantBlockBody
          end

          class If < Liquid::If
            include TolerantBlockBody
          end

          class TableRow < Liquid::TableRow
            include TolerantBlockBody
          end

          class Unless < Liquid::Unless
            include TolerantBlockBody
          end
        end
      end
    end
  end
end
