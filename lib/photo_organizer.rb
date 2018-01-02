# encoding: UTF-8
require 'find'
require 'mini_exiftool'
require 'pathname'
require 'fileutils'
require_relative 'exif_parser'

class PhotoOrganizer
  def initialize(h={})
    @in_dir = Dir.pwd + "/" + (h[:in_dir] || "from")
    ymdhm = (Time.now).strftime('%Y%m%d-%H%M%S')
    @out_dir_base = Dir.pwd + "/" + (h[:out_dir] || "result-#{ymdhm}")
  end

  def run
    unless FileTest.directory?(@in_dir)
      warn "--from must be a directory: #{self.path_short(@in_dir)}"
      exit
    end

    puts "dir from: #{self.path_short(@in_dir)}"
    puts "dir to:   #{self.path_short(@out_dir_base)}"

    handler = ->(file) do
      ex = ExifParser.get_info(file)
      to_path = self.build_copy_to_path(ex)
      self.copy_file_from_to(file, to_path)
    end
    
    find_files_and_do(@in_dir, handler)
  end

  protected
  def find_files_and_do(dir, handler)
    Find.find(dir) do |path|
      next if FileTest.directory?(path)
      unless (File.basename(path).match(/^[^.].+?\.(jpg|png|mov|mp4)$/i))
        warn "un-supported file: #{self.path_short(path)}"
        next
      end
      handler.call(path)
    end
  end

  def build_copy_to_path(exif)
    ext_def = {
      JPEG: { ext:"jpg", dir:"photos/" },
      PNG:  { ext:"png", dir:"photos/" },
      MOV:  { ext:"mov", dir:"movies/" },
      MP4:  { ext:"mp4", dir:"movies/" }
    }
    ed = ext_def[exif[:type].to_sym]
    unless ed
      warn "unknown extension: #{exif[:filename]}"
      return
    end
    path = Pathname.new @out_dir_base + "/#{ed[:dir]}" + exif[:t].strftime("%Y/%Y_%m_%d/%Y_%m_%d_%H%M%S.#{ed[:ext]}")
    return path
  end

  def copy_file_from_to(from_path, to_path)
    FileUtils.mkdir_p(to_path.dirname) unless to_path.dirname.directory?
    if to_path.exist?
      to_path = Pathname.new to_path.to_s.gsub(/(\.\w+)$/, "-#{Time.now.strftime('%3L')}\\1")
    end
    FileUtils.copy_file(from_path, to_path)
    puts "copied: #{self.path_short(to_path)}"
  end

  def path_short(path)
    return Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd))
  end
end


