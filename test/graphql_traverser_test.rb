# frozen_string_literal: true

require "test_helper"

class GraphqlTraverserTest < Minitest::Test
  def test_aliases
    graphql_file = PlatformosCheck::GraphqlFile.new(
      "app/graphql/records.graphql",
      make_storage(
        "app/graphql/records.graphql" => '
        query {
          records{
            total_entries
            results {
              id
              key: property(name: "key")
            }
          }
        }'
      )
    )

    fields = PlatformosCheck::GraphqlTraverser.new(graphql_file).fields

    assert_equal(
      {
        "/" => ["records"],
        "/records" => %w[total_entries results],
        "/records/total_entries" => [],
        "/records/results" => %w[id key],
        "/records/results/id" => [],
        "/records/results/key" => []
      },
      fields
    )
  end

  def test_fragments
    graphql_file = PlatformosCheck::GraphqlFile.new(
      "app/graphql/records.graphql",
      make_storage(
        "app/graphql/records.graphql" => '
        fragment UserFields on User {
          id
          slug: property(name: "slug")
        }

        query get{
          records {
            results {
              id
              ...UserFields
            }
          }
        }'
      )
    )

    fields = PlatformosCheck::GraphqlTraverser.new(graphql_file).fields

    assert_equal(
      {
        "/" => ["records"],
        "/records" => ["results"],
        "/records/results" => %w[id slug],
        "/records/results/id" => [],
        "/records/results/slug" => []
      },
      fields
    )
  end

  def test_related_records
    graphql_file = PlatformosCheck::GraphqlFile.new(
      "app/graphql/records.graphql",
      make_storage(
        "app/graphql/records.graphql" => '
        query get{
          records {
            results {
              id
              profile: related_record {
                full_name: property(name: "full_name")
              }
            }
          }
        }'
      )
    )

    fields = PlatformosCheck::GraphqlTraverser.new(graphql_file).fields

    assert_equal(
      {
        "/" => ["records"],
        "/records" => ["results"],
        "/records/results" => %w[id profile],
        "/records/results/id" => [],
        "/records/results/profile" => ["full_name"],
        "/records/results/profile/full_name" => []
      },
      fields
    )
  end
end
