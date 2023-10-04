# frozen_string_literal: true

require "test_helper"

class ConfigTest < ActiveSupport::TestCase
  setup do
    Config.stubs(:default_config).returns({ "app_name" => "DefaultName" })
    Config.force_reload
  end

  teardown do
    Config.force_reload
  end

  def stub_env(**env)
    Config.stubs(:env).returns(env)
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
    Tempfile.create do |f|
      stub_env("REVERSER_CUSTOM_CONFIG_PATH" => f.path)
      assert_equal("DefaultName", Config.app_name)
      assert_empty(Config.custom_config)
    end
  end

  it "returns the overwritten value of the custom config" do
    Tempfile.create do |f|
      stub_env("REVERSER_CUSTOM_CONFIG_PATH" => f.path)
      f << "app_name: OverwrittenName"
      f.flush
      Config.unstub(:custom_config)
      assert_equal("OverwrittenName", Config.app_name)
    end
  end

  it "returns the overwritten value of from ENV" do
    Config.stubs(:custom_config).returns({ "app_name" => "OverwrittenName" })
    stub_env("REVERSER_APP_NAME" => "OverwrittenNameAgain")
    assert_equal("OverwrittenNameAgain", Config.app_name)
  end

  it "snips ? from env names" do
    Config.stubs(:default_config).returns({ "enabled?" => "false" })
    stub_env("REVERSER_ENABLED" => "false")
    assert_not(Config.enabled?)
  end

  [
    ["true", true],
    ["false", false],
    ["null", nil],
    ["", nil],
    ["\"\"", ""],
    ["\"test\"", "test"],
    ["1", 1],
    ["[]", []],
    ["[1, 2]", [1, 2]],
    ["{ a: 1 }", { "a" => 1 }],
  ].each do |value, expected|
    it "returns the correct type for {#{value}}:#{value.class}" do
      stub_env("REVERSER_APP_NAME" => value)
      assert_equal(expected, Config.app_name)
    end
  end
end
