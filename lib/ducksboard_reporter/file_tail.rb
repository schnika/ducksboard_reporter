module DucksboardReporter
  class FileTail

    attr_accessor :value, :timestamp, :name, :options

    def initialize(path)
      @path = path
      @timestamp = Time.now.to_i
    end

    def run
      open_file

      while true do
        if (current_time = Time.now.to_i) > @timestamp # flush every second
          @every_second_block.call(current_time)
          @timestamp = current_time
        end

        IO.select([@file])
        line = @file.gets

        if line
          @line_block.call(line)
        else
          raise Errno::ENOENT unless File.exists?(@path)
          sleep 0.001
        end
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

