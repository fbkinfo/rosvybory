require 'spec_helper'

describe SpamReportingService do
  specify '.report' do
    user_app = double phone: '555783', save: true
    user_app.should_receive(:spam).with(false)
    SpamReportingService.should_receive(:add_to_blacklist).with('555783')
    SpamReportingService.report user_app
  end

  specify '.blacklist' do
    expect { SpamReportingService.add_to_blacklist('555783') }.to change(Blacklist, :count).by(1)
  end
end
