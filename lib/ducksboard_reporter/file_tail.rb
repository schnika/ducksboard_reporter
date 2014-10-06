module DucksboardReporter
  class FileTail

    attr_accessor :value, :timestamp, :name, :options

    def initialize(path)
      @path = path
    end

    def run
      open_file

      while true do
        IO.select([@file])
        line = @file.gets

        @line_block.call(line)

        raise Errno::ENOENT if line.nil? && !File.exists?(@path)
      end
    rescue Errno::ENOENT
      sleep 0.1
      retry
    end

    def every_second(&block)
      @every_second_block = block
    end

    def on_line(&block)
      @line_block = block
    end

    private

    def open_file
      if @file && !@file.closed?
        if File.stat(@path).ino == @file.stat.ino
          return
        else
          @file.close
        end
      end

      @file = File.open(@path, "r")
      @file.seek(0, IO::SEEK_END)
    end
  end
end

