# frozen_string_literal: true

module TempFileHelper
  def with_temp_file(contents)
    file = Tempfile.new("format-text")
    file.write(contents)
    file.flush
    yield file.path
  ensure
    file.close
    file.unlink
  end
end
