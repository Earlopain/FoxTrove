require "test_helper"

class ConfigTest < ActiveSupport::TestCase
  setup do
    Config.stubs(:default_config).returns(text: "foo", bool?: true, numeric: 123)
    Config.reset_cache
  end

  teardown do
    Config.reset_cache
  end

  def stub_custom_config(**params, &)
    Tempfile.create do |f|
      stub_const(Config, :CUSTOM_PATH, Pathname.new(f.path)) do
        f << Psych.safe_dump(params.transform_keys(&:to_s))
        f.flush
        Config.unstub(:custom_config)
        yield
        Config.reset_cache
      end
    end
  end

  test "no crash when the custom config file doesn't exist" do
    stub_const(Config, :CUSTOM_PATH, Pathname.new("i_dont_exist.yml")) do
      assert_equal("foo", Config.text)
      assert_empty(Config.custom_config)
    end
  end

  test "error for unknown config entries" do
    assert_raises(NoMethodError) { Config.missing_key }
  end

  test "no crash when the custom config is empty" do
    stub_custom_config do
      assert_equal("foo", Config.text)
      assert_empty(Config.custom_config)
    end
  end

  test "the overwritten value of the custom config is returned" do
    stub_custom_config(text: "bar") do
      assert_equal("bar", Config.text)
    end
  end

  test "the config is correctly merged" do
    stub_custom_config(text: "bar", other_key: "abc") do
      assert_equal({ "text" => "baz", "other_key" => "abc" }, Config.merge_custom_config("text" => "baz"))
      assert_equal({ "text" => "baz", "other_key" => "abc" }, Config.merge_custom_config(text: "baz"))
    end
  end

  test "boolean values are merged" do
    assert_equal({ "bool?" => true }, Config.merge_custom_config("bool" => "true"))
    assert_equal({ "bool?" => false }, Config.merge_custom_config(bool?: false))
  end

  test "booleans are correctly handled" do
    stub_custom_config(bool?: true) do
      assert_predicate(Config, :bool?)
    end
    stub_custom_config(bool?: false) do
      assert_not_predicate(Config, :bool?)
    end
  end

  test "numeric values are merged" do
    assert_equal({ "numeric" => 456 }, Config.merge_custom_config("numeric" => "456"))
    assert_equal({ "numeric" => 456 }, Config.merge_custom_config("numeric" => "456.0"))
    assert_equal({ "numeric" => 456.789 }, Config.merge_custom_config("numeric" => "456.789"))
    assert_equal({ "numeric" => 456.789 }, Config.merge_custom_config("numeric" => "456,789"))
  end
end
