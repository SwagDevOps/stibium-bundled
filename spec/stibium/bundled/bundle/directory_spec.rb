# frozen_string_literal: true

# class methods -----------------------------------------------------
describe Stibium::Bundled::Bundle::Directory, :'stibium/bundled/bundle/directory' do
  # @type [Class<Stibium::Bundled::Bundle::Directory>] described_class
  :new.tap do |method|
    it { expect(described_class).to respond_to(method).with(1).arguments }
    it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:ruby_config) }
  end
end
