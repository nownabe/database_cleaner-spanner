# frozen_string_literal: true

raise "emulator is enabled" if ENV["SPANNER_EMULATOR_HOST"]

require "base64"
require "benchmark"

require_relative "../spec/spanner_admin"
require_relative "../lib/database_cleaner/spanner/deletion"

class BenchmarkRunner
  def initialize(n = 1)
    @n = n
  end

  def run
    puts "Creating instance..."
    admin.create_instance
    puts "Creating database..."
    admin.create_database
    puts

    Benchmark.bm(20) do |x|
      run_test(x, :test_batch_update)
      run_test(x, :test_delete_each)
    end
  ensure
    puts
    puts "Dropping database..."
    admin.drop_database
  end

  private

  def test_batch_update
    cleaner = DatabaseCleaner::Spanner::Deletion.new(batch_deletion: true)
    cleaner.db = db
    cleaner.clean
  end

  def test_delete_each
    cleaner = DatabaseCleaner::Spanner::Deletion.new(batch_deletion: false)
    cleaner.db = db
    cleaner.clean
  end

  def run_test(x, test_name)
    preprocess
    x.report(test_name) do
      @n.times do
        send(test_name)
      end
    end
  ensure
    postprocess
  end

  def preprocess
    client.insert("Users", [{UserId: "user1"}, {UserId: "user2"}])
    client.insert("Followings", [{FolloweeId: "user1", FollowerId: "user2"}])
    client.insert("Posts", [{PostId: "post1", UserId: "user1", Text: "text"}])
    client.insert("Bookmarks", [{UserId: "user2", PostId: "post1"}])
    client.insert("Images", [{PostId: "post1", ImageId: "image1", Image: Base64.encode64("")}])
    client.insert("Replies", [{PostId: "post1", ReplyId: "reply1", UserId: "user2", Text: "text"}])
    client.insert("Likes", [{PostId: "post1", LikerId: "user2"}])
    client.insert("ChatRooms", [{ChatRoomId: "chatRoom1", ChatRoomName: "name"}])
    client.insert("ChatRoomMembers", [{ChatRoomId: "chatRoom1", UserId: "user1"}])
    client.insert("ChatRoomMessages", [{ChatRoomId: "chatRoom1", ChatRoomMessageId: "chatRoomMessage1", UserId: "user1", Text: "text"}])
    client.insert("Communities", [{CommunityId: "community1", CommunityName: "name", OwnerId: "user1"}])
    client.insert("CommunityBelongings", [{UserId: "user1", CommunityId: "community1"}])
    client.insert("CommunityPosts", [{CommunityId: "community1", PostId: "post1"}])
  end

  def postprocess
    %w[
      Users Followings Posts Bookmarks Images Replies Likes
      ChatRooms ChatRoomMembers ChatRoomMessages
      Communities CommunityBelongings CommunityPosts
    ].each do |table|
      count = count_rows(table)
      if count != 0
        raise "#{table} was not cleaned up"
      end
    end
  end

  def count_rows(table)
    result = client.execute_query("SELECT COUNT(1) FROM #{table}")
    result.rows.first[0]
  end

  def admin
    @admin ||= SpannerAdmin.new(
      project_id: project_id,
      instance_id: instance_id,
      database_id: database_id,
      schema_file: File.expand_path("./schema.sql", __dir__)
    )
  end

  def client
    @client ||= Google::Cloud::Spanner.new(project_id: project_id)
      .client(instance_id, database_id)
  end

  def project_id
    @project_id ||= SpannerAdmin.get_project_id
  end

  def instance_id
    @instance_id ||= ENV.fetch("SPANNER_INSTANCE_ID")
  end

  def database_id
    @database_id ||= "performance-#{Time.now.to_i}"
  end

  def db
    @db ||= {
      project_id: project_id,
      instance_id: instance_id,
      database_id: database_id
    }
  end
end

BenchmarkRunner.new(100).run
