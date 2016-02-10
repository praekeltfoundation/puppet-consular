require 'spec_helper'

describe 'consular::repo' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile }

      describe 'with default parameters' do
        it { is_expected.to contain_class('apt') }
        it { is_expected.to contain_apt__ppa('ppa:jerith/consular') }
      end

      describe 'when manage is false' do
        let(:params) { { :manage => false } }
        it { is_expected.not_to contain_class('apt') }
        it { is_expected.not_to contain_apt__ppa('ppa:jerith/consular') }
      end

      describe 'with an unknown source' do
        let(:params) { { :source => 'test' } }
        it do
          is_expected.to raise_error(/APT repository 'test' is not supported./)
        end
      end
    end
  end
end
