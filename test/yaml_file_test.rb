# frozen_string_literal: true

require "test_helper"

class YamlFileTest < Minitest::Test
  def setup
    @yaml = make_yaml_file("translations/en/my-file.yml", "---")
  end

  def test_name
    assert_equal("translations/en/my-file", @yaml.name)
  end

  def test_relative_path
    assert_equal("translations/en/my-file.yml", @yaml.relative_path.to_s)
  end

  def test_content
    assert_empty(@yaml.content)
  end

  def test_content_with_error
    @yaml = make_yaml_file("translations/en/my-file.yml", "---\nhello: world\nfail")

    assert_nil(@yaml.content)
  end

  def test_parse_error
    assert_nil(@yaml.parse_error)
  end

  def test_parse_error_with_error
    @yaml = make_yaml_file("translations/en/my-file.yml", "---\nhello: world\nfail")

    assert_instance_of(Psych::SyntaxError, @yaml.parse_error)
  end

  def test_write
    storage = make_storage("translations/en/my-file.yml" => 'hello: friend')
    @yaml = PlatformosCheck::YamlFile.new("translations/en/my-file.yml", storage)
    @yaml.update_contents({ 'hello' => "world" })
    @yaml.write

    assert_equal("---\nhello: world\n", storage.read("translations/en/my-file.yml"))
  end

  private

  def make_yaml_file(name, content)
    storage = make_storage(name => content)
    PlatformosCheck::YamlFile.new(name, storage)
  end
end
