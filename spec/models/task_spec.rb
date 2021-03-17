require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validation' do
    before(:each) do
      @user = create(:user)
    end
    it 'is valid with all attributes' do
      task = Task.new(
        id: 1,
        content: "test",
        title: "title",
        status: 1,
        created_at: Time.now,
        updated_at: Time.now,
        user_id: 1
      )
      #expect(task).to be_valid
      expect(task).to be_valid
    end

    it 'is invalid without title' do
      task = Task.new(title: nil)
      task.valid?
      expect(task.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without status' do
      task = Task.new(status: nil)
      task.valid?
      expect(task.errors[:status]).to include("can't be blank")
    end

    it 'is invalid with a duplicate title' do
      task1 = Task.create(title: "title1", status: 1, user_id: 1)
      task2 = Task.create(title: "title1", status: 1, user_id: 1)
      task2.valid?
      expect(task2.errors[:title]).to include("has already been taken")
    end

    it 'is valid with another title' do
      task1 = Task.create(title: "title1", status: 1, user_id: 1)
      task2 = Task.create(title: "title2", status: 1, user_id: 1)
      expect(task2).to be_valid
    end
  end
end