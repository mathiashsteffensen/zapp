# frozen_string_literal: false

require("spec_helper")

RSpec.describe(Zapp::InputStream) do
  subject(:input) { described_class.new(string: raw_string) }

  let(:raw_string) { "this is http data" }

  describe("#gets") do
    context("when no input has previously been read") do
      it("returns the whole string") do
        expect(input.gets).to(eq(raw_string))
      end
    end

    context("when all input has been previously read") do
      it("returns nil for EOF") do
        input.gets
        expect(input.gets).to(be_nil)
      end
    end
  end

  describe("#read") do
    subject(:read) { input.read(length, buffer) }

    let(:length) { nil }
    let(:buffer) { nil }

    context("with no arguments") do
      context("when nothing has been read from the input") do
        it("returns the whole input") do
          expect(read).to(eq(raw_string))
        end
      end

      context("when SOME input has been previously read") do
        it("returns the rest of the string") do
          input.read(5)
          expect(read).to(eq("is http data"))
        end

        context("when rewinded") do
          it("returns the whole input") do
            input.read(5)
            input.rewind
            expect(read).to(eq(raw_string))
          end
        end
      end

      context("when ALL input has been previously read") do
        it("returns an empty string for EOF") do
          input.read
          expect(read).to(eq(""))
        end
      end
    end

    context("with a length argument") do
      let(:length) { 5 }

      context("when nothing has been read from the input") do
        it("returns 5 bytes of the string") do
          expect(read).to(eq("this "))
        end

        it("has a bytesize of 5") do
          expect(read.bytesize).to(eq(5))
        end
      end

      context("when SOME input has been previously read") do
        before do
          input.read(5)
        end

        it("returns the rest of the string") do
          expect(read).to(eq("is ht"))
        end

        it("has a bytesize of 5") do
          expect(read.bytesize).to(eq(5))
        end
      end

      context("when ALL input has been previously read") do
        it("returns an empty nil for EOF") do
          input.read
          expect(read).to(be_nil)
        end
      end
    end

    context("with a buffer") do
      let(:buffer) { "" }

      context("when nothing has been read from the input") do
        it("adds the whole input to the buffer") do
          read
          expect(buffer).to(eq(raw_string))
        end
      end
    end
  end

  describe("#each") do
    subject(:each) { input.each }

    it("calls read and wraps it in an array") do
      each do |s|
        expect(s).to(eq(raw_string))
      end
    end
  end
end
