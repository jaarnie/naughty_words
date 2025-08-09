RSpec.describe NaughtyWords do
  describe "#check" do
    context "when the string contains profanity" do
      it "returns true" do
        string = "fuck you"

        expect(NaughtyWords.check(string: string)).to eq(true)
      end
    end

    context "when the string has special characters with profanity" do
      it "returns true" do
        string = "my_fucking_offensive_username!@£$%^&*()_+"

        expect(NaughtyWords.check(string: string)).to eq(true)
      end
    end

    context "when the string does not contain profanity" do
      it "returns false" do
        string = "my_username_string"

        expect(NaughtyWords.check(string: string)).to eq(false)
      end
    end

    context "when names/words with profanity are in the string" do
      it "returns false" do
        %w[mpassell baldasso cummings].each do |string|
          expect(NaughtyWords.check(string: string)).to eq(false)
        end
      end
    end

    context "with allow list" do
      it "returns false if similar word on allow list" do
        string = "scunthorpe"

        expect(NaughtyWords.check(string: string)).to eq(false)
      end

      it "returns true if similar word not on allow list" do
        string = "cunt"

        expect(NaughtyWords.check(string: string)).to eq(true)
      end
    end

    context "with severity levels" do
      before do
        NaughtyWords::WordList.create!(word: "bad_word", list_type: "deny", severity: "high")
        NaughtyWords::WordList.create!(word: "medium_word", list_type: "deny", severity: "medium")
        NaughtyWords::WordList.create!(word: "low_word", list_type: "deny", severity: "low")
      end

      it "allows bypassing low severity words" do
        word = "low_word"
        is_profane = NaughtyWords.check(string: word)
        expect(is_profane).to be true

        is_profane = false if NaughtyWords::WordList.by_severity("low").pluck(:word).include?(word)
        expect(is_profane).to be false
      end

      it "can check only high severity words" do
        word = "bad_word"
        is_profane = NaughtyWords::WordList.by_severity("high").pluck(:word).include?(word)
        expect(is_profane).to be true

        word = "medium_word"
        is_profane = NaughtyWords::WordList.by_severity("high").pluck(:word).include?(word)
        expect(is_profane).to be false
      end

      it "can combine severity with categories" do
        NaughtyWords::WordList.create!(
          word: "insult_word",
          list_type: "deny",
          severity: "high",
          category: "insults"
        )

        high_severity_insults = NaughtyWords::WordList.by_severity("high")
                                                     .by_category("insults")
                                                     .pluck(:word)

        expect(high_severity_insults).to include("insult_word")
        expect(high_severity_insults).not_to include("bad_word")
      end
    end
  end

  describe "#filter" do
    context "when the string contains profanity" do
      it "returns a string with profanity replaced with the default replacement" do
        string = "fuck you"

        expect(NaughtyWords.filter(string: string)).to eq("**** you")
      end

      it "returns a string with profanity replaced with the specified replacement" do
        string = "fuck you"
        replacement = "@"

        expect(NaughtyWords.filter(string: string, replacement: replacement)).to eq("@@@@ you")
      end
    end

    context "when the string has special characters with profanity" do
      it "returns a string with profanity replaced with the default replacement" do
        string = "my_fucking_offensive_username!@£$%^&*()_+"

        expect(NaughtyWords.filter(string: string)).to eq("my_*******_offensive_username!@£$%^&*()_+")
      end
    end

    context "when the string does not contain profanity" do
      it "returns the string" do
        string = "hello world"

        expect(NaughtyWords.filter(string: string)).to eq(string)
      end
    end
  end

  describe "#add_to_list" do
    context "when deny_list" do
      it "adds the string to the deny_list" do
        # TODO: get those spec fixture .txt files sorted
      end
    end
  end
end
