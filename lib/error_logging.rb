module ErrorLogging
  def self.log(location, message)
    path = Rails.root.join('log', 'error.txt') 
    File.open(path, 'a') do |f|  
      f.puts "****************************************************"
      f.puts "ERROR: " + location
      f.puts "Type: " + message
      f.puts "Time: " + DateTime.current.to_s + " UTC"
      f.puts "****************************************************\n"
    end
  end
end