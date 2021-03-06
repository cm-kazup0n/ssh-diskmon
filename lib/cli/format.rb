# フォーマットの骨格実装
class BasicFormat
  attr_reader :opts

  def initialize(opts)
    @opts = opts
  end

  def self.create(opts)
    case opts[:format]
    when :json
      JsonFormat.new(opts)
    when :compact
      CompactFormat.new(opts)
    when :table
      TableFormat.new(opts)
    else
      raise ArgumentError, "Invalid format: #{opts[:format]}"
    end
  end
end

# コンパクト表示
class CompactFormat < BasicFormat
  COLS = %w[use_percent used avail name].freeze

  def format(result)
    puts COLS.join(' ')
    result.each do |r|
      puts COLS.map { |key| unit(r, key) }.join(' ')
      puts r[:ssh] if opts[:show_ssh]
    end
  end

  private

  def unit(r, key)
    key = key.to_sym
    case key
    when :use_percent
      r[key].to_s + '%'
    when :name
      '@' + r[key]
    else
      r[key]
    end
  end
end

# JSON表示
class JsonFormat < BasicFormat
  def format(result)
    result.each do |r|
      copy = r.dup
      copy.delete :ssh unless opts[:show_ssh]
      puts copy.to_json
    end
  end
end

# テーブル形式表示
class TableFormat < BasicFormat
  require 'table_print'

  def format(result)
    if opts[:show_ssh]
      tp result
    else
      tp result, except: :ssh
    end
  end
end
