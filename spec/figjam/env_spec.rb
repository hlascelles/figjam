require "spec_helper"

describe Figjam::ENV do
  subject(:env) { described_class }

  before do
    ::ENV["HELLO"] = "world"
    ::ENV["foo"] = "bar"
  end

  describe "#method_missing" do
    context "with plain methods" do
      it "makes ENV values accessible as lowercase methods" do
        expect(env.hello).to eq("world")
        expect(env.foo).to eq("bar")
      end

      it "makes ENV values accessible as uppercase methods" do
        expect(env.HELLO).to eq("world")
        expect(env.FOO).to eq("bar")
      end

      it "makes ENV values accessible as mixed-case methods" do
        expect(env.Hello).to eq("world")
        expect(env.fOO).to eq("bar")
      end

      it "returns nil if no ENV key matches" do
        expect(env.goodbye).to be_nil
      end

      it "respects a stubbed plain method" do
        allow(env).to receive(:bar).and_return("baz") # rubocop:disable RSpec/SubjectStub
        expect(env.bar).to eq("baz")
      end
    end

    # rubocop:disable RSpec/RepeatedSubjectCall
    context "with bang methods" do
      it "makes ENV values accessible as lowercase methods" do
        expect(env.hello!).to eq("world")
        expect(env.foo!).to eq("bar")
      end

      it "makes ENV values accessible as uppercase methods" do
        expect(env.HELLO!).to eq("world")
        expect(env.FOO!).to eq("bar")
      end

      it "makes ENV values accessible as mixed-case methods" do
        expect(env.Hello!).to eq("world")
        expect(env.fOO!).to eq("bar")
      end

      it "raises an error if no ENV key matches" do
        expect { env.goodbye! }.to raise_error(Figjam::MissingKey)
      end

      it "respects a stubbed plain method" do
        allow(env).to receive(:bar).and_return("baz") # rubocop:disable RSpec/SubjectStub
        expect { expect(env.bar!).to eq("baz") }.not_to raise_error
      end
    end

    context "with boolean methods" do
      it "returns true for accessible, lowercase methods" do
        expect(env.hello?).to be(true)
        expect(env.foo?).to be(true)
      end

      it "returns true for accessible, uppercase methods" do
        expect(env.HELLO?).to be(true)
        expect(env.FOO?).to be(true)
      end

      it "returns true for accessible, mixed-case methods" do
        expect(env.Hello?).to be(true)
        expect(env.fOO?).to be(true)
      end

      it "returns false if no ENV key matches" do
        expect(env.goodbye?).to be(false)
      end

      it "respects a stubbed plain method" do
        allow(env).to receive(:bar).and_return("baz") # rubocop:disable RSpec/SubjectStub
        expect(env.bar?).to be(true)
      end
    end

    context "with setter methods" do
      it "raises an error for accessible, lowercase methods" do
        expect { env.hello = "world" }.to raise_error(NoMethodError)
        expect { env.foo = "bar" }.to raise_error(NoMethodError)
      end

      it "raises an error for accessible, uppercase methods" do
        expect { env.HELLO = "world" }.to raise_error(NoMethodError)
        expect { env.FOO = "bar" }.to raise_error(NoMethodError)
      end

      it "raises an error for accessible, mixed-case methods" do
        expect { env.Hello = "world" }.to raise_error(NoMethodError)
        expect { env.fOO = "bar" }.to raise_error(NoMethodError)
      end

      it "raises an error if no ENV key matches" do
        expect { env.goodbye = "world" }.to raise_error(NoMethodError)
      end
    end
    # rubocop:enable RSpec/RepeatedSubjectCall
  end

  describe "#respond_to?" do
    context "with plain methods" do
      it "returns true for accessible, lowercase methods" do
        expect(env.respond_to?(:hello)).to be(true)
        expect(env.respond_to?(:foo)).to be(true)
      end

      it "returns true for accessible uppercase methods" do
        expect(env.respond_to?(:HELLO)).to be(true)
        expect(env.respond_to?(:FOO)).to be(true)
      end

      it "returns true for accessible mixed-case methods" do
        expect(env.respond_to?(:Hello)).to be(true)
        expect(env.respond_to?(:fOO)).to be(true)
      end

      it "returns true if no ENV key matches" do
        expect(env.respond_to?(:baz)).to be(true)
      end
    end

    context "with bang methods" do
      it "returns true for accessible, lowercase methods" do
        expect(env.respond_to?(:hello!)).to be(true)
        expect(env.respond_to?(:foo!)).to be(true)
      end

      it "returns true for accessible uppercase methods" do
        expect(env.respond_to?(:HELLO!)).to be(true)
        expect(env.respond_to?(:FOO!)).to be(true)
      end

      it "returns true for accessible mixed-case methods" do
        expect(env.respond_to?(:Hello!)).to be(true)
        expect(env.respond_to?(:fOO!)).to be(true)
      end

      it "returns false if no ENV key matches" do
        expect(env.respond_to?(:baz!)).to be(false)
      end
    end

    context "with boolean methods" do
      it "returns true for accessible, lowercase methods" do
        expect(env.respond_to?(:hello?)).to be(true)
        expect(env.respond_to?(:foo?)).to be(true)
      end

      it "returns true for accessible uppercase methods" do
        expect(env.respond_to?(:HELLO?)).to be(true)
        expect(env.respond_to?(:FOO?)).to be(true)
      end

      it "returns true for accessible mixed-case methods" do
        expect(env.respond_to?(:Hello?)).to be(true)
        expect(env.respond_to?(:fOO?)).to be(true)
      end

      it "returns true if no ENV key matches" do
        expect(env.respond_to?(:baz?)).to be(true)
      end
    end

    context "with setter methods" do
      it "returns false for accessible, lowercase methods" do
        expect(env.respond_to?(:hello=)).to be(false)
        expect(env.respond_to?(:foo=)).to be(false)
      end

      it "returns false for accessible uppercase methods" do
        expect(env.respond_to?(:HELLO=)).to be(false)
        expect(env.respond_to?(:FOO=)).to be(false)
      end

      it "returns false for accessible mixed-case methods" do
        expect(env.respond_to?(:Hello=)).to be(false)
        expect(env.respond_to?(:fOO=)).to be(false)
      end

      it "returns false if no ENV key matches" do
        expect(env.respond_to?(:baz=)).to be(false)
      end
    end
  end
end
