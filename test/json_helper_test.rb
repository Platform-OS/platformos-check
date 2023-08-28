# frozen_string_literal: true

require "test_helper"

module PlatformosCheck
  class JsonHelperTest < Minitest::Test
    def test_set
      assert_equal({ "a" => { "b" => 1 } }, JsonHelper.set({}, 'a.b', 1))
      assert_equal({ "a" => { "b" => 1 } }, JsonHelper.set({}, %w[a b], 1))
      assert_equal({ "a" => { "b" => 1 } }, JsonHelper.set({ "a" => { "b" => 0 } }, 'a.b', 1))
      assert_equal({ "a" => { "1" => "str" } }, JsonHelper.set({ "a" => "b" }, 'a.1', "str"))
      assert_equal({ "a" => { "b" => "str" } }, JsonHelper.set({ "a" => "b" }, 'a.b', "str"))
      assert_equal({ "a" => 1 }, JsonHelper.set({ "a" => { "b" => 1 } }, 'a', 1))
    end

    def test_delete
      hash = { "a" => { "b" => 111, "c" => 222 } }

      assert_equal(111, JsonHelper.delete(hash, 'a.b'))
      assert_equal(222, JsonHelper.delete(hash, %w[a c]))
      assert_nil(JsonHelper.delete(hash, 'a.b'))
      assert_equal({ "a" => {} }, hash)
    end

    def test_json_corrector_recursively_adds_keys_through_arrays
      json = {
        "array" => [
          {},
          {},
          {}
        ]
      }

      assert_equal(
        {
          "array" => [
            { "a" => 1 },
            { "a" => 1 },
            { "a" => 1 }
          ]
        },
        JsonHelper.json_corrector(json, "array.a", 1)
      )
    end

    def test_json_corrector_deeply_adds_keys
      json = {
        "deep" => {
          "object" => {}
        }
      }

      assert_equal(
        {
          "deep" => {
            "object" => {
              "a" => 1
            }
          }
        },
        JsonHelper.json_corrector(json, %w[deep object a], 1)
      )
    end

    def test_json_corrector_deeply_adds_keys_in_array_by_id
      json = {
        "deep" => [
          { "id" => "hi" },
          { "id" => "oh" }
        ]
      }

      assert_equal(
        {
          "deep" => [
            { "id" => "hi", "ho" => "ho" },
            { "id" => "oh" }
          ]
        },
        JsonHelper.json_corrector(json, "deep.hi.ho", "ho")
      )
    end
  end
end
