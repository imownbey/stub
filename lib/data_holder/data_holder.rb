class DataHolder
  attr_reader :sums, :deviations

  def initialize(calculation, opts = {})
    @calculation = calculation
    @sums = {}
    @counts = {}
    @deviations = {}
    @instant_counts = {}

    @opts = opts

    @results = {}
  end

  def add_datapoint(opts)
    raise ArgumentError, "Must have instant" unless opts[:instant]
    raise ArgumentError, "Must have group" unless opts[:group]

    opts[:value] ||= 0 # Null values are the same as 0

    @results[opts[:instant]] ||= {}
    @results[opts[:instant]][opts[:group]] = opts[:value]

    @sums[opts[:group]] ||= 0
    if opts[:count] && @calculation == "AVG"
      @sums[opts[:group]] += opts[:count].to_i * opts[:value]
    else
      @sums[opts[:group]] += opts[:value]
    end

    if opts[:stddev]
      @deviations[opts[:instant]] ||= {}
      @deviations[opts[:instant]][opts[:group]] ||= 0
      @deviations[opts[:instant]][opts[:group]] += opts[:stddev]
    end

    @counts[opts[:group]] ||= 0
    @counts[opts[:group]] += opts[:count].to_i

    if opts[:count]
      @instant_counts[opts[:instant]] ||= 0
      @instant_counts[opts[:instant]] += opts[:count]
    end
  end

  def groups
    top_results.map {|instant, groups| groups.keys}.flatten.uniq
  end

  def normalize sample_rate
    return self if @normalized
    @results = @results.each do |instant, groups|
      groups.keys.each do |key|
        @results[instant][key] *= sample_rate
      end
    end
    @normalized = true
    self
  end

  def to_hash
    top_results
  end

  def make_traffic_independent
    @results.each do |instant, groups|
      groups.keys.each do |key|
        @results[instant][key] = @results[instant][key].to_f / @instant_counts[instant]
      end
    end

    self
  end

  private

  def top_results
    @results
  end
end
