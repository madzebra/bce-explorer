task default: :sync

namespace :db do
  def run_with_lock(script)
    lockfile = '/tmp/bce-explorer.lock'
    return if File.exist? lockfile
    begin
      mode = ::File::CREAT | ::File::EXCL | ::File::WRONLY
      File.open(lockfile, mode) { |f| f.write '1' }
      ruby script
    ensure
      File.delete lockfile
    end
  end

  task :sync do
    run_with_lock './tasks/db_sync.rb'
  end

  task :index do
    run_with_lock './tasks/db_index.rb'
  end
end
