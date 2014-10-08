module DucksboardReporter
  class FileTail
    include Celluloid::Logger
    class FileNotReadyForReadError < StandardError; end

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

        raise FileNotReadyForReadError if line.nil? && !file_ready_for_read?
      end
    rescue Errno::ENOENT, FileNotReadyForReadError
      sleep 0.5
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
          debug(log_format("Inode changed (#{@file.stat.ino} => #{new_inode}). Closing file."))
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

    def file_ready_for_read?
      @file && !@file.closed? && File.stat(@path).ino == @file.stat.ino
    end
  end
end

