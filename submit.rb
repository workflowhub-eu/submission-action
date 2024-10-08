require 'json'
require 'rest-client'
require 'ro_crate'
require 'yaml'

raise "Missing API_TOKEN" if ENV['API_TOKEN'].nil?
OUTPUT = File.open(ENV['GITHUB_OUTPUT'], 'w')
puts "Switching to: #{ENV['GITHUB_WORKSPACE']}"
Dir.chdir(ENV['GITHUB_WORKSPACE'])

config = {}
config = YAML.load_file('.workflowhub.yml') if File.exist?('.workflowhub.yml')

team_id = config.delete('team_id') || ARGV[0]
raise "Missing Team ID" if team_id.nil?
puts "::debug::Team ID: #{team_id}"

instance = config.delete('instance') || ARGV[1] || 'https://workflowhub.eu'
puts "::debug::Instance: #{instance}"

url = "#{instance.chomp('/')}/workflows/submit"
workflows = config['workflows'] || [config]
registered = []
workflows.each_with_index do |workflow, i|
  path = workflow.delete('path') || '.'
  metadata_path = Pathname.new(path).join('ro-crate-metadata.json')
  if metadata_path.exist?
    puts "Found: #{path}"
    crate = ROCrate::Reader.read(path)
    file = "crate-#{i}.crate.zip"
    puts "  Zipping..."
    ROCrate::Writer.new(crate).write_zip(file)

    body = {
      'workflow[project_ids][]' => team_id,
      'ro_crate' => File.open(file, 'rb'),
      multipart: true
    }

    headers = {
      'Authorization' => "Token #{ENV['API_TOKEN']}",
      'User-Agent' => 'GH (https://github.com/workflowhub-eu/submission-action)'
    }

    puts "  Uploading..."
    begin
      response = JSON.parse(RestClient.post(url, body, **headers))
      location = "#{instance.chomp('/')}#{response.dig('data', 'links', 'self')}"
      registered << { name: crate['name'] || path, url: location }
      puts "  Done: #{location}"
    rescue RestClient::ExceptionWithResponse => e
      STDERR.puts "Error uploading RO-Crate: #{e.message}"
      STDERR.puts e.http_body
      exit 1
    end
  else
    raise "Couldn't find #{metadata_path}"
  end
  puts
end

File.open(ENV['GITHUB_OUTPUT'], 'w') do |out|
  out.puts("workflow_urls<<EOF")
  registered.each do |w|
    out.puts(w[:url])
  end
  out.puts("EOF")
end

summary = "#{registered.count} workflows submitted"
if registered.any?
  summary += "\n\n"
  registered.each do |w|
    summary += " - #{w[:name]} <#{w[:url]}>\n"
  end
end
File.write(ENV['GITHUB_STEP_SUMMARY'], summary)

puts "Finished!"
