require 'rails_helper'

RSpec.describe Trade, type: :model do
  describe 'associations' do
    it { should belong_to(:proposer).class_name('User') }
    it { should belong_to(:receiver).class_name('User') }
    it { should belong_to(:proposer_item).class_name('Item') }
    it { should belong_to(:receiver_item).class_name('Item') }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending accepted rejected cancelled completed]) }

    context 'custom validations' do
      let(:user1) { create(:user) }
      let(:user2) { create(:user) }
      let(:item1) { create(:item, user: user1) }
      let(:item2) { create(:item, user: user2) }

      it 'prevents users from trading with themselves' do
        trade = build(:trade, proposer: user1, receiver: user1, proposer_item: item1, receiver_item: item2)
        expect(trade).not_to be_valid
        expect(trade.errors[:base]).to include('Cannot trade with yourself')
      end

      it 'prevents trading unavailable items' do
        item1.update(status: 'traded')
        trade = build(:trade, proposer: user1, receiver: user2, proposer_item: item1, receiver_item: item2)
        expect(trade).not_to be_valid
      end

      it 'validates users own their items' do
        trade = build(:trade, proposer: user1, receiver: user2, proposer_item: item2, receiver_item: item1)
        expect(trade).not_to be_valid
      end
    end
  end

  describe 'scopes' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:item1) { create(:item, user: user1) }
    let(:item2) { create(:item, user: user2) }
    let!(:pending_trade) { create(:trade, proposer: user1, receiver: user2, proposer_item: item1, receiver_item: item2, status: 'pending') }
    let!(:accepted_trade) { create(:trade, :accepted, proposer: user1, receiver: user2, proposer_item: create(:item, user: user1), receiver_item: create(:item, user: user2)) }

    it 'returns pending trades' do
      expect(Trade.pending).to include(pending_trade)
      expect(Trade.pending).not_to include(accepted_trade)
    end

    it 'returns trades for a specific user' do
      user3 = create(:user)
      expect(Trade.for_user(user1.id)).to include(pending_trade, accepted_trade)
      expect(Trade.for_user(user3.id)).to be_empty
    end
  end

  describe 'methods' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:item1) { create(:item, user: user1) }
    let(:item2) { create(:item, user: user2) }
    let(:trade) { create(:trade, proposer: user1, receiver: user2, proposer_item: item1, receiver_item: item2) }

    it 'accepts a trade' do
      expect(trade.accept!).to be true
      expect(trade.reload.status).to eq('accepted')
    end

    it 'rejects a trade' do
      expect(trade.reject!).to be true
      expect(trade.reload.status).to eq('rejected')
    end

    it 'cancels a trade' do
      expect(trade.cancel!).to be true
      expect(trade.reload.status).to eq('cancelled')
    end

    it 'completes a trade and updates items' do
      trade.update(status: 'accepted')
      expect(trade.complete!).to be true
      expect(trade.reload.status).to eq('completed')
      expect(item1.reload.status).to eq('traded')
      expect(item2.reload.status).to eq('traded')
    end
  end
end
