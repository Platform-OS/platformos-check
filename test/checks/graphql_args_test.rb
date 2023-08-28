# frozen_string_literal: true

require "test_helper"

class GraphqlArgsTest < Minitest::Test
  def test_report_unknown_argument
    offenses = render_graphql_markup('{% graphql res = "records/search", id: 10, page: 2, invalid: "Hey", key: "hello" %}')

    assert_offenses(<<~END, offenses)
      Undefined argument `invalid` provided to `app/graphql/records/search.graphql` at app/views/pages/index.liquid:1
    END
  end

  def test_does_not_report_valid_arguments
    offenses = render_graphql_markup('{% graphql res = "records/search", id: 10, page: 2, key: "hello" %}')

    assert_offenses("", offenses)
  end

  def test_does_not_report_when_using_args
    offenses = render_graphql_markup('{% graphql res = "records/search", args: id: 10, page: 2, key: "hello" %}')

    assert_offenses("", offenses)
  end

  def test_report_not_providing_required_argument
    offenses = render_graphql_markup('{% graphql res = "records/search", page: 10 %}')

    assert_offenses(<<~END, offenses)
      Required argument `id` not provided to `app/graphql/records/search.graphql` at app/views/pages/index.liquid:1
      Required argument `key` not provided to `app/graphql/records/search.graphql` at app/views/pages/index.liquid:1
    END
  end

  def test_report_parsing_error
    offenses = analyze_platformos_app(
      PlatformosCheck::GraphqlArgs.new,
      "app/views/pages/index.liquid" => '{% graphql res = "records/search", key: "hello" %}',
      "app/graphql/records/search.graphql" => <<~END
              query search(
          $id: ID!,
          $limit: Int = 20,
          $page: Int = 1,
           {
          records(
            per_page: $limit
            page: page
            filter: {
              id: { value: $id }
              table: { value: "records" }
              properties: [
                { name: "key", value: $key },
                ]
            }
          ) {
            total_entries
            total_pages
            has_previous_page
            has_next_page
            results {
              id
              key: property(name: "key")
            }
        }

      END
    )

    assert_offenses(<<~END, offenses)
      GraphQL Parse error triggered by `app/graphql/records/search.graphql`: Parse error on "{" (LCURLY) at [5, 4] at app/views/pages/index.liquid:1
    END
  end

  private

  def render_graphql_markup(graphql_tag)
    analyze_platformos_app(
      PlatformosCheck::GraphqlArgs.new,
      "app/views/pages/index.liquid" => graphql_tag,
      "app/graphql/records/search.graphql" => <<~END
              query search(
          $id: ID!,
          $limit: Int = 20,
          $page: Int = 1,
          $key: String!,
          ) {
          records(
            per_page: $limit
            page: $page
            filter: {
              id: { value: $id }
              table: { value: "records" }
              properties: [
                { name: "key", value: $key },
                ]
            }
          ) {
            total_entries
            total_pages
            has_previous_page
            has_next_page
            results {
              id
              key: property(name: "key")
            }
          }
        }

      END
    )
  end
end
