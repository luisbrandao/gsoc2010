class Host
  attr_reader :info
    
  def self.filter(*args)
    config = Configuration.find :first
    
    if not args[0].nil?
      urls_from_args = args[0].split(',')  
      base_query = config.query_base + ' ' + config.query_where
      query = self.add_where_to_query(base_query, urls_from_args)
      
      self.run_query_and_process_results(query, config)
    end
  end

  def initialize(host_info)
    @info = host_info
  end
   
  def to_xml(options = {})
    config = Configuration.find :first
    
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    field_names = config.data_field_friendly_name.split(",")
    xml.host(:uri => @info[config.filter_field_name]) do
      field_names.each do |field|
        if field != config.filter_field_name
          eval("xml.#{field}(@info[field])")
        end
      end
    end
    xml
  end
  
  private
  
  def self.run_query_and_process_results(query, config)
    host_list = ActiveRecord::Base.connection.execute(query)
     
    hosts = Array.new
    field_names = config.data_field_friendly_name.split(",")
         
    host_list.each do |host_info|
      host_data = Hash.new
      field_names.each_with_index do |field, index|
        host_data[field] = host_info[index]
      end
      hosts.push(host_data)
    end
    
    hosts.map { |host_info| new(host_info)}
  end
  
  def self.add_where_to_query(query, url_array)
    query << ' ('
    url_array.each do |arg|
      query << '\'' + arg + '\'' + ','
      puts query
    end
    query = query.chop << ')'
  end
end