require 'spec_helper'
describe 'cnsnpuppet' do
  context 'with default values for all parameters' do
    it { should contain_class('cnsnpuppet') }
  end
end
