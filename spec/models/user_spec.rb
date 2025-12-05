require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
    it { should validate_uniqueness_of(:google_id).allow_nil }
    it { should validate_inclusion_of(:provider).in_array(%w[email google]) }

    context 'for email provider' do
      it 'validates password length' do
        user = build(:user, provider: 'email', password: '12345')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end
    end

    context 'for google provider' do
      it 'does not require password' do
        user = build(:user, :google_user, password: nil, password_digest: nil)
        expect(user).to be_valid
      end
    end
  end

  describe 'callbacks' do
    it 'downcases email before saving' do
      user = create(:user, email: 'USER@EXAMPLE.COM')
      expect(user.reload.email).to eq('user@example.com')
    end
  end

  describe 'password authentication' do
    let(:user) { create(:user, password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrong_password')).to be_falsey
    end
  end

  describe '.from_google' do
    let(:google_data) do
      {
        sub: 'google-123',
        email: 'test@gmail.com',
        name: 'Test User',
        picture: 'https://example.com/photo.jpg'
      }
    end

    context 'when user does not exist' do
      it 'creates a new user' do
        expect {
          User.from_google(google_data)
        }.to change(User, :count).by(1)
      end

      it 'sets google attributes' do
        user = User.from_google(google_data)
        expect(user.google_id).to eq('google-123')
        expect(user.email).to eq('test@gmail.com')
        expect(user.name).to eq('Test User')
        expect(user.picture).to eq('https://example.com/photo.jpg')
        expect(user.provider).to eq('google')
      end
    end

    context 'when user already exists with same email' do
      let!(:existing_user) { create(:user, email: 'test@gmail.com') }

      it 'does not create a new user' do
        expect {
          User.from_google(google_data)
        }.not_to change(User, :count)
      end

      it 'updates user with google data' do
        user = User.from_google(google_data)
        expect(user.id).to eq(existing_user.id)
        expect(user.google_id).to eq('google-123')
        expect(user.provider).to eq('google')
      end
    end

    context 'when google user already exists' do
      let!(:existing_user) { create(:user, :google_user, email: 'test@gmail.com', google_id: 'google-123') }

      it 'returns existing user' do
        user = User.from_google(google_data)
        expect(user.id).to eq(existing_user.id)
      end
    end
  end
end
