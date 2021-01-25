# frozen_string_literal: true

# constants ---------------------------------------------------------
describe Stibium::Bundled, :'stibium/bundled' do
  [
    :Bundle,
    :VERSION,
  ].each do |k|
    it { expect(described_class).to have_constant(k) }
  end

  it do
    lambda do
      require 'kamaze/version'

      Kamaze::Version
    end.call.tap do |klass|
      expect(described_class.const_get(:VERSION)).to be_a(klass)
    end
  end
end

# class methods -----------------------------------------------------
describe Stibium::Bundled, :'stibium/bundled' do
  :call.tap do |method|
    it { expect(described_class).to respond_to(method) }
    it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:basedir) }
    [:env, :ruby_config].each do |keyword|
      it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(:basedir, keyword) }
    end
  end
end

# included ----------------------------------------------------------
sham!(:bundled).builder.tap do |builder|
  describe builder.call, :'stibium/bundled' do
    it { expect(described_class).to be_a(Stibium::Bundled) }

    { bundled: nil, bundled?: false }.each do |method, value|
      it { expect(described_class).to respond_to(method).with(0).arguments }
      context ".#{method}" do
        it { expect(described_class.__send__(method)).to eq(value) }
      end
    end

    :bundled_from.tap do |method|
      context '.methods' do
        it { expect(described_class.methods).to include(method) }
      end

      context '.public_methods' do
        it { expect(described_class.public_methods).not_to include(method) }
      end
    end
  end
end

sham!(:bundled).builder.tap do |builder|
  describe builder.call, :'stibium/bundled' do
    :bundled_from.tap do |method|
      let(:altered_class) do
        described_class.tap { |c| c.singleton_class.__send__(:public, method) }
      end

      it { expect(altered_class).to respond_to(method).with(1).arguments }
      [:setup, :env, :ruby_config].each do |keyword|
        it { expect(altered_class).to respond_to(method).with(1).arguments.with_keywords(keyword) }
      end
    end
  end
end

sham!(:bundled).builder.tap do |builder|
  builder.call.tap { |c| c.singleton_class.__send__(:public, :bundled_from) }.tap do |altered_class|
    describe altered_class, :'stibium/bundled' do
      :bundled_from.tap do |method|
        it { expect(described_class).to respond_to(method).with(1).arguments }
        [:setup, :env, :ruby_config].each do |keyword|
          it { expect(described_class).to respond_to(method).with(1).arguments.with_keywords(keyword) }
        end
      end
    end
  end
end

# samples -----------------------------------------------------------
sham!(:'samples/bundles').lister.call.each do |_, sample|
  describe sample.builder.call, :'stibium/bundled', :samples do
    context ".bundled_from(#{sample.basedir.to_s.inspect})" do
      it { expect(described_class).to be_a(Stibium::Bundled) }

      { bundled: [NilClass, Stibium::Bundled::Bundle], bundled?: [TrueClass, FalseClass] }.each do |method, types|
        it { expect(described_class).to respond_to(method).with(0).arguments }

        context ".#{method}" do
          it do
            expect(described_class.__send__(method).class).to satisfy("be in #{types}") { |x| types.include?(x) }
          end
        end
      end

      { bundled?: 0, bundled: 1, }.each do |method, index|
        context ".#{method}" do
          it { expect(described_class.public_send(method)).to be_a(sample.outcome.call(:bundled, index)) }
        end
      end
    end
  end
end
