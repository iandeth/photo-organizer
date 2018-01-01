# encoding: UTF-8

class ExifParser
  def self.get_info(file)
    ex = MiniExiftool.new(file)
    return { t: ex.filemodifydate, type: ex.filetype, filename: ex.filename }
  end
end
