require "rexml/document"

class Host
  attr_reader :uri
  attr_writer :uri
  attr_reader :uri_data

  def self.search(search_params)
    if search_params.nil?
      return
    end
    # create an hash to store temporary data per host
    hosts_info = Hash.new
    
    # get repository list for user
    repositories = Repository.user_repositories
      
    # for each repository
    repositories.each do |repo|
      repository_name = repo.name
      repository_uri = repo.uri
      repository_plugin_type = repo.plugin.name
      username = repo.username
      password = repo.password

      # query the data store and parse the returned XML
      begin
        hosts = eval("#{repository_plugin_type}_query(#{'repository_uri'},#{'search_params'}, #{'username'}, #{'password'})")
        hosts_xml = REXML::Document.new(hosts)

        # each element is a different host, i.e a different URL
        hosts_xml.elements.each('hosts/host') do |host_properties|
          uri = get_uri_unique_name(host_properties.attributes['uri'])
          puts "URI #{uri}"
          hosts_info[uri] = Array.new if hosts_info[uri].nil?
        
          host_properties.elements.each do |host_property|
            property_name = host_property.name
            property_value = host_property.text
            hosts_info[uri] << HostProperty.new(repository_uri, repository_name, property_name, property_value)
          end
        end
      rescue Exception => exc
        Rails.logger.error("Failed to connect to repository - #{repository_name} - #{exc.message}")
      end  
    end
    
    # map URIs data to the Host class
    hosts_info.each do |host_uri, host_info|
      new(host_uri, host_info)
    end
  end

  def initialize(uri, uri_data)
    @uri = uri
    @uri_data = uri_data
  end

  private
  def self.get_uri_unique_name(uri)
    uri = uri.downcase
    if not uri.starts_with? "http://" and not uri.starts_with? "https://"
      uri = "http://" + uri
    end
    if not uri.starts_with? "http://www." and not uri.starts_with? "https://www."
      uri = uri.gsub("https://", "https://www.")
      uri = uri.gsub("http://", "http://www.")
    end  
    if uri.ends_with? "/"
      return uri
    else
      return uri + "/"
    end
  end
end