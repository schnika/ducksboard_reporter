require "fileutils"
require "etc"

module Rund
  extend self

  def daemonize!
    # Keeep $stderr IO to display error and debug messages until
    # daemonizing is finished
    keep_local_stderr

    File.umask(0000)
    Process.daemon(true, true)
    change_group if @group
    change_user  if @user
    write_pid    if @pid_file
    change_dir
    redirect_output
    redirect_input

    close_local_stderr
  end

  def log_file=(path)
    @log_file = clean_path(path)
  end

  def pid_file=(path)
    @pid_file = clean_path(path)
  end

  def run_dir=(path)
    @run_dir = clean_path(path)
  end

  def input_file=(path)
    @input_file = clean_path(path)
  end

  def user=(user)
    @user = user
  end

  def group=(group)
    @group = group
  end

  def debug=(flag)
    @debug = !!flag
  end

  private

  def change_user
    error("Not running as root. Cannot change user of process.") if Process.uid != 0
    begin
      user = (@user.is_a? Integer) ? Etc.getpwuid(@user) : Etc.getpwnam(@user)
    rescue ArgumentError
      error("User #{@user} does not exist")
    end

    debug { "Changing user to #{user.name} UID=#{user.uid}" }

    Process::UID.change_privilege(user.uid)
  end

  def change_group
    error("Not running as root. Cannot change group of process.") if Process.uid != 0
    begin
      group = (@group.is_a? Integer) ? Etc.getgrgid(@group) : Etc.getgrnam(@group)
    rescue ArgumentError
      error("Group #{@group} does not exist")
    end

    debug { "Changing group to #{group.name} GID=#{group.gid}" }

    begin
      Process::GID.change_privilege(group.gid)
    rescue Errno::EPERM
      error("Cannot change to group #{group.name}. Permission denied.")
    end
  end

  def keep_local_stderr
    @stderr = $stderr.dup
    @stderr.sync
  end

  def close_local_stderr
    @stderr.close
  end

  def clean_path(path)
    path = path.to_s.strip
    path.empty? ? nil : File.absolute_path(path)
  end

  def change_dir
    @run_dir ||= "/"
    debug { "Changing to #{@run_dir} as run dir" }
    Dir.chdir(@run_dir)
  end

  def redirect_output
    @log_file ||= "/dev/null"
    debug { "Logging to #{@log_file}" }

    log_dir = File.dirname(@log_file)
    error("Log file dir does not exist #{log_dir}") unless File.exists?(log_dir)

    begin
      unless File.exists?(@log_file)
        FileUtils.touch(@log_file)
        File.chmod(0644, @log_file)
      end
    rescue Errno::EACCES
      error("Cannot write log file #{@log_file}. Permission denied.")
    end

    $stderr.reopen(@log_file, "a")
    $stdout.reopen($stderr)
    $stdout.sync = $stderr.sync = true
  end

  def redirect_input
    @input_file ||= "/dev/null"
    $stdin.reopen(@input_file, "r")
  end

  def write_pid
    debug { "Writing pid to #{@pid_file}" }

    begin
      File.open(@pid_file, File::CREAT | File::EXCL | File::WRONLY) {|f| f.write("#{Process.pid}") }
    rescue Errno::EACCES
      error("Cannot write pid file #{@pid_file}. Permission denied.")
    rescue Errno::EEXIST
      check_pid
      retry
    end

    at_exit do
      begin
        File.delete(@pid_file) if @pid_file && File.exists?(@pid_file)
      rescue Errno::EACCES
        debug { "Cannot delete pid file #{@pid_file}. Permission denied." }
      end
    end
  end

  def pid_status
    return :exited unless File.exists?(@pid_file)
    return :dead if pid == 0

    Process.kill(0, pid) # check process status
    :running
  rescue Errno::ESRCH
    :dead
  rescue Errno::EPERM
    :not_owned
  end

  def check_pid
    case pid_status
    when :running, :not_owned
      error("A process is already running with pid #{pid}")
    when :dead
      debug { "Deleting stale pid file" }
      File.delete(@pid_file)
    end
  end

  def pid
    @pid ||= File.read(@pid_file).strip.to_i
  end

  def error(msg)
    @stderr << "ERROR: #{msg}\n"
    exit 1
  end

  def debug(msg = nil)
    return unless @debug
    msg = yield if block_given?
    @stderr << "DEBUG: #{msg}\n"
  end

  def error(msg)
    @stderr << "ERROR: #{msg}\n"
    exit 1
  end
end
