require_relative "list_topics.rb"

require "rspec"

describe "list_topics" do
  before(:all) do
    @topics = read_topic_file("topics-test.csv")
  end

  describe "#read_topic_file" do
    it "reads all topics" do
      expect(@topics.keys).to eq(["One", "Three", "Two"])
    end

    it "reads libraries for topic" do
      expect(@topics["One"]).to eq(["liba", "libd"])
      expect(@topics["Two"]).to eq(["libd", "libb", "libe"])
      expect(@topics["Three"]).to eq(["libc"])
    end
  end

  describe "#print_topics" do
    it "prints all topics" do
      expected_output = <<EOT
One (2): liba, libd
Three (1): libc
Two (3): libb, libd, libe
EOT
      expect { print_topics(@topics) }.to output(expected_output).to_stdout
    end
  end
end
