class XlsxRenderer

  def initialize(klazz)
    @klazz = klazz

    @pkg = Axlsx::Package.new
    @pkg.use_shared_strings = true # Numbers compatibility
    @sheet = @pkg.workbook.add_worksheet(:name => klazz.model_name.human(:count => 0))

    @styles = @pkg.workbook.styles

    @header_style = @styles.add_style(:fg_color => 'FF888888', :b => true)
  end

  def iterate(collection, &block)
    @sheet.add_row HeaderPrinter.new(@klazz).instance_exec(&block).to_a, :style => @header_style

    collection.each do |record|
      @sheet.add_row ValuesPrinter.new(record).instance_exec(&block).to_a
    end
  end

  def data
    @pkg.to_stream.read
  end

  class HeaderPrinter
    def initialize(klazz)
      @klazz = klazz
      @cols = []
    end

    def column(name)
      @cols << if name.is_a? String
        name
      else
        @klazz.human_attribute_name(name)
      end
    end

    def to_a
      @cols
    end
  end

  class ValuesPrinter
    def initialize(record)
      @cols = []
      @record = record
    end

    def column(name)
      @cols << if block_given?
        yield @record
      else
        @record.send(name)
      end
    end

    def to_a
      @cols
    end
  end

end
