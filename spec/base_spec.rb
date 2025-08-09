# frozen_string_literal: true

RSpec.describe NaughtyWords::Base do
  describe ".profanity?" do
    context "with invalid input" do
      it "raises ArgumentError for nil input" do
        expect { described_class.profanity?(string: nil) }.to raise_error(ArgumentError)
      end

      it "raises ArgumentError for non-string input" do
        expect { described_class.profanity?(string: 123) }.to raise_error(ArgumentError)
      end
    end

    context "with default configuration" do
      it "returns true when string contains word from deny list" do
        string = "fuck you"
        expect(described_class.profanity?(string: string)).to be true
      end

      it "returns false when string contains word from allow list" do
        string = "scunthorpe"
        expect(described_class.profanity?(string: string)).to be false
      end

      it "returns false when string contains no profanity" do
        string = "hello world"
        expect(described_class.profanity?(string: string)).to be false
      end
    end

    context "with word boundaries" do
      before do
        NaughtyWords::Config.configure { |config| config.word_boundaries = true }
      end

      after do
        NaughtyWords::Config.reset!
      end

      it "matches whole words only" do
        expect(described_class.profanity?(string: "fuck")).to be true
        expect(described_class.profanity?(string: "fuckthis")).to be false
        expect(described_class.profanity?(string: "this_fuck_that")).to be true
      end
    end

    context "without word boundaries" do
      before do
        NaughtyWords::Config.configure { |config| config.word_boundaries = false }
      end

      after do
        NaughtyWords::Config.reset!
      end

      it "matches substrings" do
        expect(described_class.profanity?(string: "fuck")).to be true
        expect(described_class.profanity?(string: "fuckthis")).to be true
        expect(described_class.profanity?(string: "this_fuck_that")).to be true
        expect(described_class.profanity?(string: "motherfucker")).to be true
      end

      it "filters substrings" do
        expect(described_class.filter(string: "fuckthis")).to eq("****this")
        expect(described_class.filter(string: "motherfucker")).to eq("************")
        expect(described_class.filter(string: "this_fuck_that")).to eq("this_****_that")
        expect(described_class.filter(string: "fuck this and fuck that")).to eq("**** this and **** that")
      end
    end

    context "with word overrides" do
      after do
        NaughtyWords::Config.reset!
      end

      it "allows overridden deny list words" do
        string = "fuck"  # This is in the deny list
        expect(described_class.profanity?(string: string)).to be true

        NaughtyWords::Config.allow_word("fuck")
        expect(described_class.profanity?(string: string)).to be false
      end

      it "denies overridden allow list words" do
        string = "scunthorpe"  # This is in the allow list
        expect(described_class.profanity?(string: string)).to be false

        NaughtyWords::Config.deny_word("scunthorpe")
        expect(described_class.profanity?(string: string)).to be true
      end

      it "handles removing overrides" do
        string = "fuck"
        NaughtyWords::Config.allow_word("fuck")
        expect(described_class.profanity?(string: string)).to be false

        NaughtyWords::Config.remove_override("fuck")
        expect(described_class.profanity?(string: string)).to be true
      end

      it "affects filtering" do
        string = "fuck shit"  # Both in deny list
        NaughtyWords::Config.allow_word("fuck")
        expect(described_class.filter(string: string)).to eq("fuck ****")
      end

      it "is case insensitive" do
        string = "FUCK"
        NaughtyWords::Config.allow_word("fuck")
        expect(described_class.profanity?(string: string)).to be false
      end

      it "handles multiple overrides" do
        string = "fuck shit cunt"  # All in deny list
        NaughtyWords::Config.allow_word("fuck")
        NaughtyWords::Config.allow_word("shit")
        expect(described_class.filter(string: string)).to eq("fuck shit ****")
      end
    end
  end

  describe ".filter" do
    context "with invalid input" do
      it "raises ArgumentError for nil input" do
        expect { described_class.filter(string: nil) }.to raise_error(ArgumentError)
      end

      it "raises ArgumentError for non-string input" do
        expect { described_class.filter(string: 123) }.to raise_error(ArgumentError)
      end

      it "raises ArgumentError for nil replacement" do
        expect { described_class.filter(string: "test", replacement: nil) }.to raise_error(ArgumentError)
      end

      it "raises ArgumentError for empty replacement" do
        expect { described_class.filter(string: "test", replacement: "") }.to raise_error(ArgumentError)
      end
    end

    context "with default configuration" do
      it "replaces profanity with asterisks" do
        string = "fuck you"
        expect(described_class.filter(string: string)).to eq("**** you")
      end

      it "preserves original string length" do
        string = "fuck this shit"
        result = described_class.filter(string: string)
        expect(result.length).to eq(string.length)
      end

      it "uses custom replacement character" do
        string = "fuck you"
        expect(described_class.filter(string: string, replacement: "#")).to eq("#### you")
      end

      it "handles integer replacements" do
        string = "fuck you"
        expect(described_class.filter(string: string, replacement: "5")).to eq("5555 you")
      end

      it "doesn't modify strings without profanity" do
        string = "hello world"
        expect(described_class.filter(string: string)).to eq(string)
      end

      it "handles consecutive profanities" do
        string_1 = "fuckfuckfuckhello"
        string_2 = "fuckthisshitusername"
        string_3 = "fuck_this_shitty_fucking_validation"

        expect(described_class.filter(string: string_1)).to eq("************hello")
        expect(described_class.filter(string: string_2)).to eq("****this****username")
        expect(described_class.filter(string: string_3)).to eq("****_this_******_*******_validation")
      end
    end
  end

  describe ".show_list" do
    context "with invalid input" do
      it "raises ArgumentError for invalid list type" do
        expect { described_class.show_list(list: "invalid") }.to raise_error(ArgumentError)
      end
    end

    context "with valid input" do
      it "returns array of words for deny list" do
        expect(described_class.show_list(list: "deny")).to include("fuck")
      end

      it "returns array of words for allow list" do
        expect(described_class.show_list(list: "allow")).to include("scunthorpe")
      end
    end
  end
end

