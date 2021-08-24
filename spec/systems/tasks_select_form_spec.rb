require 'rails_helper'

RSpec.describe 'tasks selec form', type: :system do
  let(:user)  { create(:user) }
  let(:tasks_title) { page.all('.card-title') }
  before do
    create(:task, user_id: user.id, title: "created_at 1 week before", 
                    created_at: 1.week.before, deadline: Time.zone.now)
    create(:task, user_id: user.id, title: "created_at 1 week after", 
                    created_at: 1.week.after,  deadline: Time.zone.now)
    create(:task, user_id: user.id, title: "deadline 1 week before", 
                    created_at: Time.zone.now, deadline: 1.week.before)
    create(:task, user_id: user.id, title: "deadline 1 week after", 
                    created_at: Time.zone.now, deadline: 1.week.after)
    visit tasks_path
  end
  before(:example) do
    select keyword, from: 'keyword'
    click_button '並べ替え'
  end

  context "select '投稿が新しい順'" do
    let(:keyword) { '投稿が新しい順' }
    it "'created_at 1 week before' at the beginning" do
      expect(tasks_title[0].text).to eq "created_at 1 week before"
    end
    it "'created_at 1 week after' at the last" do
      expect(tasks_title[3].text).to eq "created_at 1 week after"
    end
  end
  context "select '投稿が古い順'" do
    let(:keyword) { '投稿が古い順' }
    it "'created_at 1 week after' at the beginning" do
      expect(tasks_title[0].text).to eq "created_at 1 week after"
    end
    it "'created_at 1 week before' at the last" do
      expect(tasks_title[3].text).to eq "created_at 1 week before"
    end
  end
  context "select '期限が近い順'" do
    let(:keyword) { '期限が近い順' }
    it "'deadline 1 week before' at the beginning" do
      expect(tasks_title[0].text).to eq "deadline 1 week before"
    end
    it "'deadline 1 week after' at the last" do
      expect(tasks_title[3].text).to eq "deadline 1 week after"
    end
  end
  context "select '期限が遠い順'" do
    let(:keyword) { '期限が遠い順' }
    it "'deadline 1 week after' at the beginning" do
      expect(tasks_title[0].text).to eq "deadline 1 week after"
    end
    it "'deadline 1 week before' at the last" do
      expect(tasks_title[3].text).to eq "deadline 1 week before"
    end
  end
end
