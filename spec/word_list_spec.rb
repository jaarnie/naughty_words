# frozen_string_literal: true

RSpec.describe NaughtyWords::WordList do
  if defined?(ActiveRecord)
    describe "validations" do
      it "requires a word" do
        word_list = described_class.new(list_type: "deny")
        expect(word_list).not_to be_valid
        expect(word_list.errors[:word]).to include("can't be blank")
      end

      it "requires a list_type" do
        word_list = described_class.new(word: "test")
        expect(word_list).not_to be_valid
        expect(word_list.errors[:list_type]).to include("can't be blank")
      end

      it "only allows 'deny' or 'allow' as list_type" do
        word_list = described_class.new(word: "test", list_type: "invalid")
        expect(word_list).not_to be_valid
        expect(word_list.errors[:list_type]).to include("is not included in the list")
      end

      it "enforces uniqueness of word within list_type" do
        described_class.create!(word: "test", list_type: "deny")
        duplicate = described_class.new(word: "test", list_type: "deny")
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:word]).to include("has already been taken")
      end

      it "allows same word in different list types" do
        described_class.create!(word: "test", list_type: "deny")
        allow_list = described_class.new(word: "test", list_type: "allow")
        expect(allow_list).to be_valid
      end
    end

    describe "scopes" do
      before do
        described_class.destroy_all
        @denied = described_class.create!(word: "bad", list_type: "deny")
        @allowed = described_class.create!(word: "good", list_type: "allow")
      end

      describe ".deny_list" do
        it "returns only denied words" do
          expect(described_class.deny_list).to include(@denied)
          expect(described_class.deny_list).not_to include(@allowed)
        end
      end

      describe ".allow_list" do
        it "returns only allowed words" do
          expect(described_class.allow_list).to include(@allowed)
          expect(described_class.allow_list).not_to include(@denied)
        end
      end
    end

    describe "word normalization" do
      it "always downcases words" do
        word = described_class.create!(word: "Test", list_type: "deny")
        expect(word.reload.word).to eq("test")
      end
    end

    describe "metadata" do
      it "supports optional context" do
        word = described_class.create!(
          word: "test",
          list_type: "deny",
          context: "Added for testing"
        )
        expect(word.reload.context).to eq("Added for testing")
      end

      it "supports optional added_by" do
        word = described_class.create!(
          word: "test",
          list_type: "deny",
          added_by: "test@example.com"
        )
        expect(word.reload.added_by).to eq("test@example.com")
      end

      it "tracks timestamps" do
        word = described_class.create!(word: "test", list_type: "deny")
        expect(word.created_at).to be_present
        expect(word.updated_at).to be_present
      end
    end
  else
    describe "without ActiveRecord" do
      it "provides empty lists" do
        expect(described_class.deny_list).to eq([])
        expect(described_class.allow_list).to eq([])
      end
    end
  end
end 
