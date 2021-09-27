def get_command_line_argument
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

domain = get_command_line_argument

dns_raw = File.readlines("zone")

def parse_dns(raw)
  raw.
    map {|line| line.strip}.
    reject {|line| line.empty? || line[0] == '#'}.
    map {|line| line.split(", ") }.
    each_with_object({}) do |item, array|
      array[item[1]] = {type: item[0], target: item[2]}
    end
end

def resolve(dns_records, lookup_chain, domain)
    record = dns_records[domain]
    if (!record)
      lookup_chain = "Error: Record not found for " + domain
    elsif record[:type] == "CNAME"
      lookup_chain.push(record[:target])
      resolve(dns_records, lookup_chain, record[:target])
    elsif record[:type] == "A"
      lookup_chain.push(record[:target])
    else
      lookup_chain = "Invalid record type for " + domain
    end
end

dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
