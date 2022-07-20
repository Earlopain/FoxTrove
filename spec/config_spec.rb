# frozen_string_literal: true

RSpec.describe Config do
  before do
    allow(described_class).to receive(:default_config).and_return({
      "app_name" => "DefaultName",
      "boolean_key?" => true,
    })
    stub_const("ENV", {
      "REVERSER_CUSTOM_CONFIG_PATH" => "/empty/file",
    })
    described_class.force_reload
  end

  def stub_add_to_env(**values)
    stub_const("ENV", { **ENV, **values })
  end

  it "works when the custom config file doesn't exist" do
    # This is the default stub
    expect(described_class.app_name).to eq("DefaultName")
    expect(described_class.custom_config).to eq({})
  end

  it "raises an error for unknown config entries" do
    expect { described_class.missing_key }.to raise_error(NoMethodError)
  end

  it "returns the value of the default value" do
    expect(described_class.app_name).to eq("DefaultName")
  end

  it "works when the custom config file is empty" do
    Tempfile.create do |f|
      stub_add_to_env("REVERSER_CUSTOM_CONFIG_PATH" => f.path)
      expect(described_class.app_name).to eq("DefaultName")
      expect(described_class.custom_config).to eq({})
    end
  end

  it "returns the overwritten value of the custom config" do
    Tempfile.create do |f|
      stub_add_to_env("REVERSER_CUSTOM_CONFIG_PATH" => f.path)
      f << "app_name: OverwrittenName"
      f.flush
      expect(described_class.app_name).to eq("OverwrittenName")
    end
  end

  it "returns the overwritten value of from ENV" do
    allow(described_class).to receive(:custom_config).and_return({ "app_name" => "OverwrittenName" })
    stub_add_to_env("REVERSER_APP_NAME" => "OverwrittenNameAgain")
    expect(described_class.app_name).to eq("OverwrittenNameAgain")
  end

  it "snips ? from env names" do
    stub_add_to_env("REVERSER_BOOLEAN_KEY" => "false")
    expect(described_class.boolean_key?).to be(false)
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
      stub_const("ENV", {
        "REVERSER_APP_NAME" => value,
      })
      expect(described_class.app_name).to eq(expected)
    end
  end
end
