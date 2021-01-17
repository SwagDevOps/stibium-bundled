# frozen_string_literal: true

results = {
  empty: [FalseClass, NilClass],
  gemfile: [TrueClass, Stibium::Bundled::Bundle],
  gemfile_old: [TrueClass, Stibium::Bundled::Bundle],
  partial: [FalseClass, NilClass],
  partial_old: [FalseClass, NilClass],
  standalone: [TrueClass, Stibium::Bundled::Bundle]
}

lister = lambda do
  Dir.glob("#{SAMPLES_PATH}/bundles/*").map { |fp| Pathname.new(fp) }.keep_if(&:directory?).map do |fp|
    [
      fp.basename.to_s.to_sym,
      {
        basedir: fp,
        env: {},
        results: results.fetch(fp.basename.to_s.to_sym),
      }.tap do |h|
        h[:builder] = lambda do |base: Class|
          base.new do
            class << self
              include Stibium::Bundled
            end

            self.bundled_from(fp, env: h.fetch(:env))
          end
        end
      end.yield_self { |h| Struct.new(*h.keys).new(*h.values) }
    ]
  end.sort.to_h
end

builder = lambda do |name, base: Class|
  lister.call.fetch(name.to_s.to_sym).builder.call(base: base)
end

{
  lister: lister,
  builder: builder,
}
