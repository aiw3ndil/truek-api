require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:item_images).dependent(:destroy) }
    it { should have_many(:trades_as_proposer).class_name('Trade') }
    it { should have_many(:trades_as_receiver).class_name('Trade') }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_least(3).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(1000) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[available traded unavailable]) }
  end

  describe '#destroy' do
    let(:proposer) { create(:user) }
    let(:receiver) { create(:user) }
    let(:item_to_delete) { create(:item, user: proposer) }
    let(:other_item) { create(:item, user: receiver) }

    context 'when item is in a trade' do
      it 'prevents deletion if trade is pending' do
        create(:trade, proposer: proposer, receiver: receiver, proposer_item: item_to_delete, receiver_item: other_item, status: 'pending')
        expect { item_to_delete.destroy }.to_not change(Item, :count)
        expect(item_to_delete.errors[:base]).to include('Cannot delete item with active trades. Please cancel them first.')
      end

      it 'prevents deletion if trade is accepted' do
        create(:trade, proposer: proposer, receiver: receiver, proposer_item: item_to_delete, receiver_item: other_item, status: 'accepted')
        expect { item_to_delete.destroy }.to_not change(Item, :count)
        expect(item_to_delete.errors[:base]).to include('Cannot delete item with active trades. Please cancel them first.')
      end

      it 'prevents deletion if trade is completed' do
        create(:trade, proposer: proposer, receiver: receiver, proposer_item: item_to_delete, receiver_item: other_item, status: 'completed')
        expect { item_to_delete.destroy }.to_not change(Item, :count)
        expect(item_to_delete.errors[:base]).to include('Cannot delete item that is part of a completed trade.')
      end

      it 'deletes item and associated trade if trade is rejected' do
        trade = create(:trade, proposer: proposer, receiver: receiver, proposer_item: item_to_delete, receiver_item: other_item, status: 'rejected')
        expect { item_to_delete.destroy }.to change(Item, :count).by(-1)
        expect(Trade.find_by(id: trade.id)).to be_nil
      end

      it 'deletes item and associated trade if trade is cancelled' do
        trade = create(:trade, proposer: proposer, receiver: receiver, proposer_item: item_to_delete, receiver_item: other_item, status: 'cancelled')
        expect { item_to_delete.destroy }.to change(Item, :count).by(-1)
        expect(Trade.find_by(id: trade.id)).to be_nil
      end
    end

    context 'when item is not in a trade' do
      it 'deletes the item successfully' do
        item_to_delete # Create the item
        expect { item_to_delete.destroy }.to change(Item, :count).by(-1)
      end
    end
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
end
