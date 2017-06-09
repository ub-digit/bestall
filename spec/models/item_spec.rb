require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "methods" do
    context "item can be borrowed" do
      it "should return false when rules prevent item from being ordered" do
        item = Item.new(biblio_id: 1, xml: '<datafield tag="952" ind1=" " ind2=" "><subfield code="y">7</subfield></datafield>')
        expect(item.can_be_borrowed).to be_falsey
      end
      it "should return true when rules allow item to be ordered" do
        item = Item.new(biblio_id: 1, xml: '<datafield tag="952" ind1=" " ind2=" "><subfield code="y">1</subfield></datafield>')
        expect(item.can_be_borrowed).to be_truthy
      end
    end

    context "item data can be parsed" do
      before :each do
        @xml = File.open("#{Rails.root}/spec/support/biblio/biblio-1.xml") { |f|
          Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]').to_xml
        }
      end
      it "should return a barcode" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.barcode).to eq('1001821737')
      end
      it "should return an item call numer" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.item_call_number).to eq('Kursbok')
      end
      it "should return an copy number" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.copy_number).to eq('1')
      end
      it "should return an sublocation id" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.sublocation_id).to eq('400004')
      end
      it "should return a due date" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.due_date).to eq('2017-03-02')
      end
      it "should return can_be_ordered" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.can_be_ordered).to_not be_nil
      end
      it "should return not_for_loan" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.not_for_loan).to_not be_nil
      end
      it "should return is_available_for_queue" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.is_available_for_queue).to_not be_nil
      end
      it "should return a status" do
        item = Item.new(biblio_id: 1, xml: @xml)
        expect(item.status).to_not be_nil
      end
    end

    context "item is unrestricted" do
      before :each do
        @xml = File.open("#{Rails.root}/spec/support/item/item-can-order.xml") { |f|
          Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
        }
        WebMock.stub_request(:get, "http://koha.example.com/auth_values/list?category=LOC&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/sublocations/list?password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
      end
      it "should return can_be_ordered true when restricted is not present in xml" do
        item = Item.new(biblio_id: 1, xml: @xml[0].to_xml)
        expect(item.can_be_ordered).to be_truthy
      end
      it "should return can_be_ordered true when restricted is 0" do
        item = Item.new(biblio_id: 1, xml: @xml[1].to_xml)
        expect(item.can_be_ordered).to be_truthy
      end
    end

    context "item can not be ordered" do
      before :each do
        @xml = File.open("#{Rails.root}/spec/support/biblio/biblio-cannot-order.xml") { |f|
          Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
        }
        WebMock.stub_request(:get, "http://koha.example.com/auth_values/list?category=LOC&password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
        WebMock.stub_request(:get, "http://koha.example.com/sublocations/list?password=password&userid=username").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip, deflate', 'Host'=>'koha.example.com'}).
          to_return(:status => 200, :body => File.new("#{Rails.root}/spec/support/sublocation/sublocations.xml"), :headers => {})
      end
      it "should return can_be_ordered false when item type is 7" do
        item = Item.new(biblio_id: 1, xml: @xml[0].to_xml)
        expect(item.can_be_ordered).to be_falsey
      end
      it "should return can_be_ordered false when item type is 2" do
        item = Item.new(biblio_id: 1, xml: @xml[1].to_xml)
        expect(item.can_be_ordered).to be_falsey
      end
      it "should return can_be_ordered false when a due date is present" do
        item = Item.new(biblio_id: 1, xml: @xml[2].to_xml)
        expect(item.can_be_ordered).to be_falsey
      end
      it "should return can_be_ordered false when item is lost" do
        item = Item.new(biblio_id: 1, xml: @xml[3].to_xml)
        expect(item.can_be_ordered).to be_falsey
      end
      it "should return can_be_ordered false when item is restricted" do
        item = Item.new(biblio_id: 1, xml: @xml[4].to_xml)
        expect(item.can_be_ordered).to be_falsey
      end
      it "should return can_be_ordered false when item is on a non-paging location" do
        item = Item.new(biblio_id: 1, xml: @xml[5].to_xml)
        expect(item.can_be_ordered).to be_falsey
      end
      it "should return can_be_ordered false when item is reserved" do
        can_be_ordered_xml = File.open("#{Rails.root}/spec/support/item/item-can-order.xml") { |f|
          Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
        }
        item = Item.new(biblio_id: 1, xml: can_be_ordered_xml[0].to_xml)
        item.is_reserved = true
        expect(item.can_be_ordered).to be_falsey
      end
    end

    context "item is unavailable for queue" do
      before :each do
        @xml = File.open("#{Rails.root}/spec/support/item/item-cannot-queue.xml") { |f|
          Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
        }
      end
      it "should return is_available_for_queue false when item type is 7" do
        item = Item.new(biblio_id: 1, xml: @xml[0].to_xml)
        expect(item.is_available_for_queue).to be_falsey
      end
      it "should return is_available_for_queue false when restricted is 1" do
        item = Item.new(biblio_id: 1, xml: @xml[1].to_xml)
        expect(item.is_available_for_queue).to be_falsey
      end
      it "should return is_available_for_queue false when restricted is 2" do
        item = Item.new(biblio_id: 1, xml: @xml[2].to_xml)
        expect(item.is_available_for_queue).to be_falsey
      end
      it "should return is_available_for_queue false when restricted is 5" do
        item = Item.new(biblio_id: 1, xml: @xml[3].to_xml)
        expect(item.is_available_for_queue).to be_falsey
      end
      it "should return is_available_for_queue false when restricted is 6" do
        item = Item.new(biblio_id: 1, xml: @xml[4].to_xml)
        expect(item.is_available_for_queue).to be_falsey
      end

      context "when there is no due date" do
        it "should return is_available_for_queue false item is not reserved" do
          item = Item.new(biblio_id: 1, xml: @xml[5].to_xml)
          item.is_reserved = false
          expect(item.is_available_for_queue).to be_falsey
        end
        it "should return is_available_for_queue true item is reserved" do
          item = Item.new(biblio_id: 1, xml: @xml[5].to_xml)
          item.is_reserved = true
          expect(item.is_available_for_queue).to be_truthy
        end
      end
      context "when there is a due date" do
        it "should return is_available_for_queue true when item is not reserved" do
          is_available_for_queue_xml = File.open("#{Rails.root}/spec/support/item/item-can-queue.xml") { |f|
            Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
          }
          item = Item.new(biblio_id: 1, xml: is_available_for_queue_xml[0].to_xml)
          item.is_reserved = false
          expect(item.is_available_for_queue).to be_truthy
        end
        it "should return is_available_for_queue true when item is reserved" do
          is_available_for_queue_xml = File.open("#{Rails.root}/spec/support/item/item-can-queue.xml") { |f|
            Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
          }
          item = Item.new(biblio_id: 1, xml: is_available_for_queue_xml[0].to_xml)
          item.is_reserved = true
          expect(item.is_available_for_queue).to be_truthy
        end
      end
    end

    describe "can_be_queued" do
      context "item is available for queue and has item level queue" do
        before :each do
          @xml = File.open("#{Rails.root}/spec/support/item/item-can-queue.xml") { |f|
            Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
          }
        end
        it "should return can_be_queued true" do
          item = Item.new(biblio_id: 1, xml: @xml[0].to_xml, has_item_level_queue: true)
          expect(item.can_be_queued).to be_truthy
        end
      end
      context "item is unavailable for queue" do
        before :each do
          @xml = File.open("#{Rails.root}/spec/support/item/item-cannot-queue.xml") { |f|
            Nokogiri::XML(f).remove_namespaces!.search('//record/datafield[@tag="952"]')
          }
        end
        it "should return can_be_queued false when item is unavailable for queue" do
          item = Item.new(biblio_id: 1, xml: @xml[0].to_xml, has_item_level_queue: true)
          expect(item.can_be_queued).to be_falsey
        end
        it "should return can_be_queued false when item doesn't have item level queue" do
          item = Item.new(biblio_id: 1, xml: @xml[0].to_xml, has_item_level_queue: false)
          expect(item.can_be_queued).to be_falsey
        end
      end
    end
  end
end
