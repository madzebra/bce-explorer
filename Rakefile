task default: :sync

task :sync do
  lockfile = '/tmp/bce-explorer.lock'
  unless File.exist? lockfile
    begin
      mode = ::File::CREAT | ::File::EXCL | ::File::WRONLY
      File.open(lockfile, mode) { |f| f.write '1' }
      ruby './tasks/sync_rich_list.rb'
    ensure
      File.delete lockfile
    end
  end
end
