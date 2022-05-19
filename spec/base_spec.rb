RSpec.describe NaughtyWords::Base do
  describe "#profanity?" do
    context "when the string contains profanity" do
      it "returns true" do
        string = "fuck you"

        expect(NaughtyWords::Base.profanity?(string: string)).to eq(true)
      end
    end

    context "when the string does not contain profanity" do
      it "returns false" do
        string = "my_username_string"

        expect(NaughtyWords::Base.profanity?(string: string)).to eq(false)
      end
    end
  end

  describe "#filter" do
    context "when the string contains profanity" do
      it "returns a string with profanity replaced with the specified replacement" do
        replacement = "*"
        string = "fuck you"

        expect(NaughtyWords::Base.filter(string: string, replacement: replacement)).to eq("**** you")
      end

      it "returns a string with profanity replaced with the replacement converted into a string" do
        replacement = 5
        string = "fuck you"

        expect(NaughtyWords::Base.filter(string: string, replacement: replacement.to_s)).to eq("5555 you")
      end
    end

    context "when the string does not contain profanity" do
      it "returns the string" do
        string = "hello world"

        expect(NaughtyWords::Base.filter(string: string, replacement: "*")).to eq(string)
      end
    end
  end
end
