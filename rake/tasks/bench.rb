# frozen_string_literal: true

autoload(:Pathname, 'pathname')
autoload(:RbConfig, 'rbconfig')

config = {
  basedir: Pathname.new('bench').freeze,
  fname: 'bench',
}.tap do |h|
  {
    exedir: h.fetch(:basedir).join('scripts').freeze,
    outdir: h.fetch(:basedir).join('exports').freeze,
  }.yield_self { |v| h.merge!(v) }.tap do |base|
    {
      report_namer: lambda do |ext|
        base.fetch(:outdir).join("#{h.fetch(:fname)}.#{ext}")
      end,
      scripter: lambda do |fname|
        base.fetch(:exedir).join(fname.to_s.gsub(/\.rb$/, '').concat('.rb')).tap(&:realpath)
      end,
    }.yield_self { |v| base.merge!(v) }
  end
end.yield_self { |c| Struct.new(*c.keys).new(*c.values) }

unless Which.call('hyperfine').empty?
  desc 'Run benchmarks'
  task :bench do
    {
      'bundler/setup': [RbConfig.ruby, config.scripter.call(:bundler)],
      bundled: [RbConfig.ruby, config.scripter.call(:bundler)],
      'bundle exec': ['bundle', 'exec', RbConfig.ruby, config.scripter.call(:empty)],
    }.yield_self do |benchs|
      [
        'hyperfine',
        '--warmup', '3',
        '--runs', ENV.fetch('runs', 25).to_i.to_s,
        '--export-markdown', config.report_namer.call('md').to_s,
        '--export-json', config.report_namer.call('json').to_s,
        '--export-csv', config.report_namer.call('csv').to_s,
      ]
        .concat(benchs.map { |name, command| ['-n', name.to_s, command.map { |v| v.to_s.inspect }.join(' ')] }.flatten)
        .concat(ENV.fetch('debug', nil) == 'true' ? ['--show-output'] : [])
        .tap do |args|
          mkdir_p(config.outdir, verbose: true)
          sh(*args)
        end
    end
  end
end
