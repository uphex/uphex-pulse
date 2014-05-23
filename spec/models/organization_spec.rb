require 'spec_helper'
require 'spec/support/templates/active_record_model'
require 'app/models/organization'
require 'app/models/portfolio'

describe Organization do
  context "validations" do
    validation_spec_for :presence, :name
    validation_spec_for :presence, :slug
    validation_spec_for :uniqueness, :slug
  end

  context "associations" do
    association_spec_for :have_many, :portfolios
  end

  describe "#name=" do
    it "downcases and dasherizes the slug value when assigning" do
      o = described_class.new
      expect { o.name = 'Foo Bar, Inc.' }.to change { o.slug }.from(nil).to('foo-bar-inc')
    end
  end
end
