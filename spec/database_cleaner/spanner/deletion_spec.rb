# frozen_string_literal: true

require "google/cloud/spanner"
require "google/cloud/spanner/admin/database"

require "database_cleaner/spanner/deletion"

module Helper
  def count_rows(table)
    result = spanner.execute_query("SELECT COUNT(1) FROM #{table}")
    result.rows.first[0]
  end
end

RSpec.describe DatabaseCleaner::Spanner::Deletion do
  include Helper

  subject {
    described_class.new(
      only: only,
      except: except,
      batch_deletion: batch_deletion
    ).tap do |instance|
      instance.db = {
        project_id: RSpec.configuration.project_id,
        instance_id: RSpec.configuration.instance_id,
        database_id: RSpec.configuration.database_id
      }
    end
  }

  let(:spanner) {
    Google::Cloud::Spanner.new(
      project_id: RSpec.configuration.project_id
    ).client(
      RSpec.configuration.instance_id,
      RSpec.configuration.database_id
    )
  }

  # Insert test data
  before(:example) do
    spanner.insert("Products", [{ProductId: 1, Name: "product", Price: 1.0}])
    spanner.insert("Customers", [{CustomerId: 1, Name: "customer"}])
    spanner.insert("Orders", [{OrderId: 1, ProductId: 1, CustomerId: 1, Quantity: 1}])
    spanner.insert("Singers", [{SingerId: 1, Name: "singer"}])
    spanner.insert("Albums", [{SingerId: 1, AlbumId: 1, Title: "album"}])
    spanner.insert("Songs", [{SingerId: 1, AlbumId: 1, SongId: 1, Title: "song"}])

    spanner.insert("OnlyTable", [{Id: 1}])
    spanner.insert("ExceptTable", [{Id: 1}])
  end

  # Delete test data
  after(:example) do
    %w[
      Orders Products Customers
      Songs Albums Singers
      OnlyTable ExceptTable
    ].each do |t|
      # If keys aren't specified, all rows will be deleted.
      # https://googleapis.dev/ruby/google-cloud-spanner/latest/Google/Cloud/Spanner/Client.html#delete-instance_method
      # https://github.com/googleapis/ruby-spanner/blob/b5e1f51a714da5d037b211b1b0afddf8bbdb501b/google-cloud-spanner/lib/google/cloud/spanner/commit.rb#L329
      spanner.delete(t)
    end
  end

  let(:only) { [] }
  let(:except) { [] }
  let(:batch_deletion) { false }

  context "by default" do
    it "deletes all tables" do
      subject.clean

      expect(count_rows("Products")).to be_zero
      expect(count_rows("Customers")).to be_zero
      expect(count_rows("Orders")).to be_zero
      expect(count_rows("Singers")).to be_zero
      expect(count_rows("Albums")).to be_zero
      expect(count_rows("Songs")).to be_zero
      expect(count_rows("OnlyTable")).to be_zero
      expect(count_rows("ExceptTable")).to be_zero
    end
  end

  context "with batch deletion" do
    let(:batch_deletion) { true }

    it "deletes all tables" do
      subject.clean

      expect(count_rows("Products")).to be_zero
      expect(count_rows("Customers")).to be_zero
      expect(count_rows("Orders")).to be_zero
      expect(count_rows("Singers")).to be_zero
      expect(count_rows("Albums")).to be_zero
      expect(count_rows("Songs")).to be_zero
      expect(count_rows("OnlyTable")).to be_zero
      expect(count_rows("ExceptTable")).to be_zero
    end
  end

  context "with the :only option" do
    let(:only) { ["OnlyTable"] }

    it "deletes only OnlyTable table" do
      subject.clean

      expect(count_rows("Products")).not_to be_zero
      expect(count_rows("Customers")).not_to be_zero
      expect(count_rows("Orders")).not_to be_zero
      expect(count_rows("Singers")).not_to be_zero
      expect(count_rows("Albums")).not_to be_zero
      expect(count_rows("Songs")).not_to be_zero
      expect(count_rows("ExceptTable")).not_to be_zero

      expect(count_rows("OnlyTable")).to be_zero
    end
  end

  context "with the :except option" do
    let(:except) { ["ExceptTable"] }

    it "deletes tables except for ExceptTable" do
      subject.clean

      expect(count_rows("Products")).to be_zero
      expect(count_rows("Customers")).to be_zero
      expect(count_rows("Orders")).to be_zero
      expect(count_rows("Singers")).to be_zero
      expect(count_rows("Albums")).to be_zero
      expect(count_rows("Songs")).to be_zero
      expect(count_rows("OnlyTable")).to be_zero

      expect(count_rows("ExceptTable")).not_to be_zero
    end
  end
end
