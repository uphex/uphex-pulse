require 'spec_helper'
require 'uphex/extensions/object'

describe Object do
  describe "extensions" do
    it { expect(subject).to respond_to :blank? }
    it { expect(subject).to respond_to :presence }
  end
end
