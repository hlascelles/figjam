require "spec_helper"

# rubocop:disable RSpec/DescribeClass
describe "figjam install" do
  before do
    create_directory("example")
    cd("example")
  end

  it "creates a configuration file" do
    run_command_and_stop("figjam install")

    expect("config/application.yml").to be_an_existing_file
  end

  it "respects path" do
    run_command_and_stop("figjam install -p env.yml")

    expect("env.yml").to be_an_existing_file
  end

  context "with a .gitignore file" do
    before do
      write_file(".gitignore", <<~STR)
        /foo
        /bar
      STR
    end

    # rubocop:disable RSpec/ExpectActual
    it "Git-ignores the configuration file if applicable" do
      run_command_and_stop("figjam install")

      expect(".gitignore").to have_file_content(%r{^/foo$})
      expect(".gitignore").to have_file_content(%r{^/bar$})
    end
    # rubocop:enable RSpec/ExpectActual

    it "respects path" do
      run_command_and_stop("figjam install -p env.yml")
    end
  end

  context "without a .gitignore file" do
    it "doesn't generate a new .gitignore file" do
      run_command_and_stop("figjam install")

      expect(".gitignore").not_to be_an_existing_file
    end
  end
end
# rubocop:enable RSpec/DescribeClass
