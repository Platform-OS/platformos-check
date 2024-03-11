# frozen_string_literal: true

require "test_helper"

class GraphqlFileTest < Minitest::Test
  def setup
    @app_file = PlatformosCheck::GraphqlFile.new(
      "app/graphql/records/search.graphql",
      make_storage("app/graphql/records/search.graphql" => <<~GRAPHQL)
        query records_search(
          $page: Int
          $uuid: String!
        ) {
          records(
            per_page: 1
            page: $page
            filter: {
              properties: [
                { name: "uuid", value: $uuid }
              ]
            }
          ) {
            results{
              id
            }
          }
        }
      GRAPHQL
    )
  end

  def test_relative_path
    assert_equal("app/graphql/records/search.graphql", @app_file.relative_path.to_s)
  end

  def test_type
    assert_predicate(@app_file, :graphql?)
    refute_predicate(@app_file, :page?)
    refute_predicate(@app_file, :partial?)
  end

  def test_name
    assert_equal("records/search", @app_file.name)
  end

  def test_required_arguments
    assert_equal ['uuid'], @app_file.required_arguments
  end

  def test_optional_arguments
    assert_equal ['page'], @app_file.optional_arguments
  end

  def test_defined_arguments
    assert_equal %w[page uuid], @app_file.defined_arguments
  end

  def test_empty_graphql_file
    @app_file = PlatformosCheck::GraphqlFile.new(
      "app/graphql/records/empty.graphql",
      make_storage("app/graphql/records/empty.graphql" => '')
    )

    assert_empty @app_file.required_arguments
    assert_empty @app_file.defined_arguments
    assert_empty @app_file.optional_arguments
  end
end
