RSpec.describe "sample" do
  before do
    customer = create(:customer)
    product = create(:product)
    create(:order, customer: customer, product: product)
    singer = create(:singer)
    album = create(:album, singer: singer)
    create(:song, singer: singer, album: album)
  end

  it "sample" do
    expect(true).to be true
  end
end
