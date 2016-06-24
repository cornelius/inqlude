require "csv"

def read_topic_file(file)
  topics = {}
  CSV.foreach(file) do |row|
    row.each do |col|
      lib = nil
      row.each do |col|
        if !lib
          lib = col
          next
        end
        if !col || col.empty?
          next
        end
        topics[col] ||= []
        topics[col].push(lib) unless topics[col].include?(lib)
      end
    end
  end
  topics
end

def print_topics(topics)
  topics.sort.each do |topic, libs|
    puts "#{topic} (#{libs.count}): #{libs.sort.join(", ")}"
  end
end
