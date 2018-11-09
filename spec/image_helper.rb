module ImageHelper
  def fixture_file(name = nil)
    name ||= 'img.jpg'
    File.open(Pathname(__FILE__).parent.dirname.realpath.join('spec', 'fixtures', name.to_s))
  end

  def uploaded_file(name = nil)
    Rack::Test::UploadedFile.new(fixture_file(name), original_filename: name || 'img.jpg')
  end

  def post_multipart(url, params, files)
    multipart(:post, url, params, files)
  end

  def put_multipart(url, params, files)
    multipart(:put, url, params, files)
  end

  def multipart(method, url, params, files)
    json_file = Tempfile.new('blob')
    json_file << params.to_json
    json_file.flush
    send(method, url,
         files.merge(json: Rack::Test::UploadedFile.new(json_file, 'application/json')),
         'ACCEPT' => 'application/json')
  ensure
    json_file.close
    json_file.unlink
  end
end
