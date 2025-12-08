require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:item_images).dependent(:destroy) }
    it { should have_many(:trades_as_proposer).class_name('Trade').dependent(:restrict_with_error) }
    it { should have_many(:trades_as_receiver).class_name('Trade').dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[available traded unavailable]) }
  end

  describe 'scopes' do
    let!(:user) { create(:user) }
    let!(:available_item) { create(:item, user: user, status: 'available') }
    let!(:traded_item) { create(:item, user: user, status: 'traded') }

    it 'returns only available items' do
      expect(Item.available).to include(available_item)
      expect(Item.available).not_to include(traded_item)
    end

    it 'returns items by user' do
      other_user = create(:user)
      other_item = create(:item, user: other_user)
      expect(Item.by_user(user.id)).to include(available_item, traded_item)
      expect(Item.by_user(user.id)).not_to include(other_item)
    end

    it 'returns recent items first' do
      newest_item = create(:item, user: user)
      expect(Item.recent.first).to eq(newest_item)
    end
  end

  describe 'methods' do
    let(:item) { create(:item) }

    it 'returns true when item is traded' do
      item.update(status: 'traded')
      expect(item.traded?).to be true
    end

    it 'returns false when item is not traded' do
      expect(item.traded?).to be false
    end

    it 'returns true when item is available' do
      expect(item.available?).to be true
    end

    it 'returns false when item is not available' do
      item.update(status: 'traded')
      expect(item.available?).to be false
    end
  end

  describe 'nested attributes' do
    let(:user) { create(:user) }

    it 'accepts nested attributes for item_images' do
      item = Item.create(
        user: user,
        title: 'Test Item',
        description: 'Test Description',
        item_images_attributes: [
          { image_url: 'https://example.com/image1.jpg', position: 0 },
          { image_url: 'https://example.com/image2.jpg', position: 1 }
        ]
      )
      expect(item.item_images.count).to eq(2)
    end
  end
end
