module DucksboardReporter
  class FileTail
    include Celluloid::Logger

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

    def on_line(&block)
      @line_block = block
    end

    private

    def open_file
      if @file && !@file.closed?
        if (new_inode = File.stat(@path).ino) == @file.stat.ino
          return
        else
          debug(log_format("Inode changed (#{@file.stat.ino} => #{new_inode}). Reopening file."))
          @file.close
        end
      end

      @file = File.open(@path, "r")
      @file.seek(0, IO::SEEK_END)
      debug(log_format("Tailing file with inode #{@file.stat.ino}"))
    end

    def log_format(msg)
      @log_prefix ||= "FileTail (#{@path}): "
      @log_prefix + msg
    end
  end
end

