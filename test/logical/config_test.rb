# frozen_string_literal: true

require "test_helper"

class ConfigTest < ActiveSupport::TestCase
  setup do
    Config.stubs(:default_config).returns(app_name: "DefaultName", bool?: true)
    Config.reset_cache
  end

  teardown do
    Config.reset_cache
  end

  def stub_custom_config(**params, &)
    Tempfile.create do |f|
      Config.stubs(:custom_config_path).returns(f.path)
      f << Psych.safe_dump(params.transform_keys(&:to_s))
      f.flush
      Config.unstub(:custom_config)
      yield
      Config.reset_cache
    end
  end

  it "works when the custom config file doesn't exist" do
    # This is the default stub
    assert_equal("DefaultName", Config.app_name)
    assert_empty(Config.custom_config)
  end

  it "raises an error for unknown config entries" do
    assert_raises(NoMethodError) { Config.missing_key }
  end

  it "returns the value of the default value" do
    assert_equal("DefaultName", Config.app_name)
  end

  it "works when the custom config file is empty" do
    stub_custom_config do
      assert_equal("DefaultName", Config.app_name)
      assert_empty(Config.custom_config)
    end
  end

  it "returns the overwritten value of the custom config" do
    stub_custom_config(app_name: "OverwrittenName") do
      assert_equal("OverwrittenName", Config.app_name)
    end
  end

  it "merges the config correctly" do
    stub_custom_config(app_name: "OverwrittenName", other_key: "abc") do
      assert_equal({ "app_name" => "NewName", "other_key" => "abc" }, Config.merge_custom_config("app_name" => "NewName"))
      assert_equal({ "app_name" => "NewName", "other_key" => "abc" }, Config.merge_custom_config(app_name: "NewName"))
    end
  end

  it "handles booleans" do
    stub_custom_config(bool: "true") do
      assert_predicate(Config, :bool?)
    end
    stub_custom_config(bool: "false") do
      assert_not_predicate(Config, :bool?)
    end
  end
end
