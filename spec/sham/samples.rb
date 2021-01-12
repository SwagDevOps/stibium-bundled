# frozen_string_literal: true

lister = lambda do
  Dir.glob("#{SAMPLES_PATH}/*")
     .map { |fp| Pathname.new(fp) }
     .keep_if(&:directory?)
     .map { |fp| [fp.basename.to_s.to_sym, fp] }
     .to_h
end

builder = lambda do |name, base: Class|
  lister.call.fetch(name.to_s.to_sym).yield_self do |basedir|
    base.new do
      class << self
        include Stibium::Bundled
      end

      self.bundled_from(basedir)
    end
  end
end

{
  lister: lister,
  builder: builder,
}
