require 'json'
require 'rest-client'
require 'ro_crate'
require 'yaml'

raise "Missing API_TOKEN" if ENV['API_TOKEN'].nil?
OUTPUT = File.open(ENV['GITHUB_OUTPUT'], 'w')
begin
  config = {}
  if File.exist?('.workflowhub.yml')
    config = YAML.load_file('.workflowhub.yml')
    puts config.inspect
  end

  team_id = config.delete('team_id') || ARGV[0]
  instance = config.delete('instance') || ARGV[1] || 'https://workflowhub.eu'
  raise "Missing Team ID" if team_id.nil?

  url = "#{instance.chomp('/')}/workflows/submit"
  puts config.inspect

  workflows = config['workflows'] || [config]
  puts workflows
  workflows.each_with_index do |workflow, i|
    path = workflow.delete('path') || '/'
    metadata_path = Pathname.new(path).join('ro-crate-metadata.json')
    if metadata_path.exist?
      puts "Found: #{path}"
      crate = ROCrate::Reader.read(path)
      file = "crate-#{i}.crate.zip"
      puts "  Zipping..."
      ROCrate::Writer.new(crate).write_zip(file)

      body = { 'workflow[project_ids][]' => team_id,
               'ro_crate' => File.open(file, 'rb'),
               multipart: true }

      headers = {
        'Authorization' => "Token #{ENV['API_TOKEN']}",
        'User-Agent' => 'GH (https://github.com/workflowhub-eu/submission-action)'
      }

      puts "  Uploading..."
      begin
        response = JSON.parse(RestClient.post(url, body, **headers))
      rescue RestClient::ExceptionWithResponse => e
        STDERR.puts "Error uploading RO-Crate: #{e.message}"
        STDERR.puts e.http_body
        exit 1
      else
        location = "#{instance.chomp('/')}#{response.dig('data', 'links', 'self')}"
        puts "  Done: #{location}"
        OUTPUT.puts(location)
      end
    else
      raise "Couldn't find #{metadata_path}"
    end
  end
ensure
  OUTPUT.close
end

puts "\nFinished!"
exit 0