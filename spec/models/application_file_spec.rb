require 'spec_helper'

describe ApplicationFile do

  it "initializes" do
    ApplicationFile.new().should_not be_nil
  end

  # ApplicationFile is embedded in model Attachment.
  # See specs for Attachment an derived classes for more specs.

end