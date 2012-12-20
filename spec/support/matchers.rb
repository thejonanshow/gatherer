module Gatherer
  module Spec
    module Matchers
      RSpec::Matchers.define :be_valid_url do
        match do |actual|
          actual.should =~ URI::ABS_URI
        end
      end
    end
  end
end
