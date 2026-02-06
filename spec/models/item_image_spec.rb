require 'rails_helper'

RSpec.describe ItemImage, type: :model do
  describe 'associations' do
    it { should belong_to(:item) }
  end

  describe 'validations' do
    it { should have_one_attached(:file) }
    it { should validate_presence_of(:file) }
    it { should validate_numericality_of(:position).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe 'default scope' do
    let(:item) { create(:item) }
    let!(:image3) { create(:item_image, item: item, position: 2) }
    let!(:image1) { create(:item_image, item: item, position: 0) }
    let!(:image2) { create(:item_image, item: item, position: 1) }

    it 'orders by position ascending' do
      expect(item.item_images.pluck(:position)).to eq([0, 1, 2])
    end
  end
end
