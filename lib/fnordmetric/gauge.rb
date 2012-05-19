class FnordMetric::Gauge
  
  include FnordMetric::GaugeCalculations
  include FnordMetric::GaugeModifiers
  include FnordMetric::GaugeValidations
  include FnordMetric::GaugeRendering

  def initialize(opts)
    opts.fetch(:key) && opts.fetch(:key_prefix)
    @opts = opts
  end

  def tick
    (@opts[:tick] || @opts[:resolution] || 3600).to_i
  end

  def tick_at(time)    
    (time/tick.to_f).floor*tick
  end

  def name
    @opts[:key]
  end

  def title
    @opts[:title] || name
  end

  def group
    @opts[:group] || "Gauges"
  end

  def key_nouns
    @opts[:key_nouns] || ["Key", "Keys"]
  end
  
  def key(_append=nil)
    [@opts[:key_prefix], "gauge", name, tick, _append].flatten.compact.join("-")
  end

  def tick_key(_time, _append=nil)
    key([(progressive? ? :progressive : tick_at(_time).to_s), _append])
  end

  def tick_keys(_range, _append=nil)
    ticks_in(_range).map{ |_t| tick_key(_t, _append) }
  end

  def two_dimensional?
    !@opts[:three_dimensional]
  end

  def three_dimensional?
    !!@opts[:three_dimensional]
  end

  def progressive?
    !!@opts[:progressive]
  end

  def unique?
    !!@opts[:unique]
  end

  def average?
    !!@opts[:average]
  end

  def redis
    @redis ||= EM::Hiredis.connect(FnordMetric.options[:redis_url]) # FIXPAUL
  end

  def sync_redis
    @sync_redis ||= Redis.new # FIXPAUL
  end

end