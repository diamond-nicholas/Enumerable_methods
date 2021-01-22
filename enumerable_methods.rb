# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
# rubocop:disable Metrics/ModuleLength

module Enumerable
  # my each
  def my_each
    return to_enum(:my_each) unless block_given?

    arr = is_a?(Enumerable) && !is_a?(Array) ? to_a : self
    counter = 0
    while counter < size
      yield (arr[counter])
      counter += 1
    end
    self
  end

  # my_each_with_index
  def my_each_with_index
    return to_enum(:my_each_with_index) unless block_given?

    arr = is_a?(Enumerable) && !is_a?(Array) ? to_a : self
    counter = 0
    while counter < size
      yield(arr[counter], counter)
      counter += 1
    end
    self
  end

  # my_select
  def my_select
    return to_enum(:my_select) unless block_given?

    result = []
    my_each { |i| result << i if yield(i) }
    result
  end

  def my_all?(*arg)
    return grep(arg.first).length == size unless arg.empty?

    my_each { |result| return false unless yield(result) } if block_given?
    my_each { |result| return false unless result } unless block_given?
    true
  end

  # my_any?
  def my_any?(*arg)
    return !grep(arg.first).empty? unless arg.empty?

    my_each { |result| return true if yield(result) } if block_given?
    my_each { |result| return true if result } unless block_given?
    false
  end

  # my_none
  def my_none?(*arg)
    return grep(arg.first).empty? unless arg.empty?

    my_each { |result| return false if yield(result) } if block_given?
    my_each { |result| return false if result } unless block_given?
    true
  end

  # my_count
  def my_count(*arg, &block)
    return my_select { |result| result == arg.first }.length unless arg.empty?
    return my_select(&block).length if block_given?

    size
  end

  # my_map
  def my_map(par_ = nil)
    new_arr = []
    return to_enum unless block_given?

    if par_
      my_each { |i| new_arr << par_.call(i) }
    else
      my_each { |i| new_arr << yield(i) }
    end
    new_arr
  end

  # my_inject
  def my_inject(*parameter) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength, Metrics/AbcSize
    return 'wrong number of arguments' unless parameter.size <= 2

    output_array = is_a?(Array) ? self : to_a
    my_symbol = nil
    my_initial = nil
    parameter.each do |elem|
      if elem.is_a?(Symbol)
        my_symbol = elem
      else
        my_initial = elem
      end
    end

    if !my_symbol.nil? && !my_initial.nil?
      cumulator = my_initial
      each do |elem|
        cumulator = cumulator.send(my_symbol, elem)
      end
    elsif !my_symbol.nil? && my_initial.nil?
      cumulator = output_array[0]
      i = 1
      while i < size
        cumulator = cumulator.send(my_symbol, output_array[i])
        i += 1
      end
    elsif my_symbol.nil? && !my_initial.nil? && block_given?
      cumulator = my_initial
      each do |elem|
        cumulator = yield cumulator, elem
      end
    elsif my_symbol.nil? && !my_initial.nil? && !block_given?
      return "error #{my_initial} not a symbol and no block is given"
    elsif my_symbol.nil? && my_initial.nil? && block_given?
      cumulator = output_array[0]
      i = 1
      while i < size
        cumulator = yield cumulator, output_array[i]
        i += 1
      end
    else my_symbol.nil? && my_initial.nil? && !block_given?
         return to_enum(:my_inject)
    end
    cumulator
  end

  def multiply_els(arr)
    arr.inject { |total, n| total * n }
  end
end

# p %w[ant bear cat].my_all? { |word| word.length >= 3 }
# p %w[ant bear cat].my_all? { |word| word.length >= 4 }
# p %w[ant bear cat].my_all?(/t/)
# p [1, 2i, 3.14].my_all?(Numeric)
# p [nil, true, 99].my_all?
# p [].all?
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/ModuleLength
