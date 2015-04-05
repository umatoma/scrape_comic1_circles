require 'open-uri'
require 'nokogiri'

url = 'http://www.comic1.jp/CM9_circle_list2.htm'
doc = Nokogiri::HTML(open(url))

circle_infos = []
doc.css('#maincontents table').each do |table_node|
  table_node.css('tr').each do |tr_node|
    circle_info = { block: nil, space_no: nil, space_no_sub: nil, name: nil, kana: nil, url: nil }
    tr_node.css('td').each_with_index do |td_node, index|
      case index
      when 0
        circle_info[:name] = td_node.text
        a_node = td_node.at_css('a')
        circle_info[:url] = a_node[:href] if a_node
      when 1
        circle_info[:kana] = td_node.text
      when 2
        match_data = td_node.text.match(/^(\D)([0-9]{2})(a|b)$/i)
        unless match_data.nil?
          circle_info[:block] = match_data[1]
          circle_info[:space_no] = match_data[2]
          circle_info[:space_no_sub] = match_data[3]
        end
      end
    end

    circle_infos << circle_info unless circle_info.values.any?(&:nil?)
  end
end

circle_infos.sort_by! { |x| [x[:block], x[:space_no], x[:space_no_sub]] }
circle_infos.each do |circle_info|
  puts circle_info.values.join(',')
end
