require 'spec_helper'

describe 'consular' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile }

      describe 'with default parameters' do
        it do
          is_expected.to contain_class('consular::repo')
            .with({
              :manage => true,
              :source => 'ppa-jerith',
            })
        end

        it do
          is_expected.to contain_package('python-consular')
            .with_ensure('installed')
            .that_requires('Class[consular::repo]')
        end

        it do
          is_expected.to contain_file('/etc/init/consular.conf')
            .with_content(/--host 127\.0\.0\.1/)
            .with_content(/--port 7000/)
            .with_content(/--consul http:\/\/127\.0\.0\.1:8500/)
            .with_content(/--marathon http:\/\/127\.0\.0\.1:8080/)
            .with_content(/--registration-id foo/)
            .with_content(/--sync-interval 0/)
            .with_content(/--no-purge/)
            .that_requires('Package[python-consular]')
        end

        it do
          is_expected.to contain_service('consular')
            .with_ensure('running')
            .that_subscribes_to('File[/etc/init/consular.conf]')
        end
      end
    end
  end
end
