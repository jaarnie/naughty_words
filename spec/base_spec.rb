require "tempfile"

RSpec.describe NaughtyWords::Base do
  describe "#profanity?" do
    context "when the string contains profanity" do
      it "returns true" do
        string = "fuck you"

        expect(NaughtyWords::Base.profanity?(string: string)).to be(true)
      end
    end

    context "when the string does not contain profanity" do
      it "returns false" do
        string = "my_username_string"

        expect(NaughtyWords::Base.profanity?(string: string)).to be(false)
      end
    end

    context "when the string is in both deny and allow lists" do
      it "returns false" do
        # Need to create a tempfile to test this
      end
    end
  end

  describe "#filter" do
    context "when the string contains profanity" do
      it "returns a string with profanity replaced with the specified replacement" do
        replacement = "*"
        string = "fuck you"

        expect(NaughtyWords::Base.filter(string: string,
                                         replacement: replacement)).to eq("**** you")
      end

      it "returns a string with profanity replaced with the replacement converted fron an integer into a string" do
        replacement = 5
        string = "fuck you"

        expect(NaughtyWords::Base.filter(string: string,
                                         replacement: replacement.to_s)).to eq("5555 you")
      end
    end

    context "when the string has consecutive profanities" do
      it "returns a string with profanity replaced with the specified replacement" do
        replacement = "*"
        string_1 = "fuckfuckfuckhello"
        string_2 = "fuckthisshitusername"
        string_3 = "fuck_this_shitty_fucking_validation"

        expect(NaughtyWords::Base.filter(
                 string: string_1,
                 replacement: replacement
               )).to eq("************hello")

        expect(NaughtyWords::Base.filter(
                 string: string_2,
                 replacement: replacement
               )).to eq("****this****username")

        expect(NaughtyWords::Base.filter(
                 string: string_3,
                 replacement: replacement
               )).to eq("****_this_******_*******_validation")
      end
    end

    context "when the string does not contain profanity" do
      it "returns the string" do
        string = "hello world"

        expect(NaughtyWords::Base.filter(string: string, replacement: "*")).to eq(string)
      end
    end
  end

  describe "#show_ilst" do
    context "when allow list" do
      it "shows the list" do
        expect(NaughtyWords.show_list(list: "allow")).to include("scunthorpe")
      end
    end

    context "when deny list" do
      it "shows the list" do
        expect(NaughtyWords.show_list(list: "deny")).to include("fuck")
      end
    end
  end
end
