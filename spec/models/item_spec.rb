require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "methods" do
    context "item can be ordered" do
      it "should return false when rules prevent item from being ordered" do
        item = Item.new(biblio_id: 1, xml: '<datafield tag="952" ind1=" " ind2=" "><subfield code="y">7</subfield></datafield>')
        expect(item.can_be_ordered).to be_falsey
      end
      it "should return true when rules allow item to be ordered" do
        item = Item.new(biblio_id: 1, xml: '<datafield tag="952" ind1=" " ind2=" "><subfield code="y">1</subfield></datafield>')
        expect(item.can_be_ordered).to be_truthy
      end
    end
  end
end
