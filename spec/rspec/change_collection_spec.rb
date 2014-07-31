require 'spec_helper'

module RSpec
  describe ChangeCollection do
    shared_examples_for :original_change do
      it "detects simple changes" do
        array = []
        expect {
          array = [1]
        }.to change { array }
      end

      it "raises exceptions when expectations are not met" do
        array = []
        expect {
          expect {
            array << 1
          }.not_to change { array.length }
        }.to raise_exception(RSpec::Expectations::ExpectationNotMetError)
      end

      it "provides the 'from' and 'to' change helpers" do
        array = []
        expect {
          expect {
            array << 1
          }.to change { array.length }.from(0).to(2)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end

      it "provides the 'by' change helper" do
        array = []
        expect {
          expect {
            array << 1
          }.to change { array.length }.by(2)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
      end
    end

    describe "#to_include" do
      it_behaves_like :original_change

      it "succeeds when items have been added to the collection" do
        array = []
        expect {
          array += [1]
        }.to change { array} .to_include(1)
      end
      it "succeeds when multiple items have been added to the collection" do
        array = []
        expect {
          array += [1, 2]
        }.to change { array }.to_include(1,2)
      end
      it "still succeeds when the items are arrays" do
        array = []
        expect {
          array << [1]
        }.to change { array }.to_include([1])
      end
      it "fails when items have not been added to the collection" do
        array = []
        expect {
          expect {
          }.to change { array }.to_include(1)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                         /the final collection should have included.*\[1\]/)
      end
      it "fails when any item has not been added to the collection" do
        array = []
        expect {
          expect {
            array += [1]
          }.to change { array }.to_include(1,2)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                         /the final collection should have included.*\[2\]/)
      end
      it "fails when an item to include was already included" do
        array = [1]
        expect {
          expect {
          }.to change { array }.to_include(1)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                         /the original collection should not have included.*\[1\]/)
      end

      describe "with a block" do
        it "passes if initial condition is not met by non-empty-array and final condition is met" do
          array = [1,3]
          expect {
            array << 2
          }.to change { array }.to_include(&:even?)
        end

        it "passes if initial condition is not met by empty array and final condition is met" do
          array = []
          expect {
            array << 2
          }.to change { array }.to_include(&:even?)
        end

        it "fails if initial condition is not met and final condition is still not met" do
          array = [1,3]
          expect {
            expect {
              array << 5
            }.to change { array }.to_include(&:even?)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "fails if there is no change in array" do
          array = [1,3]
          expect {
            expect {
              # nop
            }.to change { array }.to_include(&:even?)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "fails if also passed an item" do
          array = []
          expect {
            expect {
              # nop
            }.to change { array }.to_include(1, &:even?)
          }.to raise_error(ArgumentError)
        end
      end
    end

    describe "#to_exclude" do
      it_behaves_like :original_change

      it "passes if the specified item has been removed from the collection" do
        array = [1]
        expect {
          array = []
        }.to change { array }.to_exclude(1)
      end

      it "passes if all of multiple specified items have been removed from the collection" do
        array = [1,2]
        expect {
          array = []
        }.to change { array }.to_exclude(1,2)
      end

      it "fails if any specified item has not been removed from the collection" do
        array = [1,2]
        expect {
          expect {
            array = [1]
          }.to change { array }.to_exclude(1,2)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                         /the final collection should not have included.*\[1\]/)
      end

      it "fails if a specified item was never in the collection" do
        array = []
        expect {
          expect {
          }.to change { array }.to_exclude(1)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                         /the original collection should have included.*\[1\]/)
      end

      it "fails if any specified item was never in the collection" do
        array = [1]
        expect {
          expect {
            array = []
          }.to change { array }.to_exclude(1,2)
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError,
                         /the original collection should have included.*\[2\]/)
      end

      describe "with a block" do
        it "passes if initial condition is met and final condition is met" do
          array = [1,2,3]
          expect {
            array -= [2]
          }.to change { array }.to_exclude(&:even?)
        end

        it "fails if initial condition is not met by non-empty collection" do
          array = [1,3]
          expect {
            expect {
              array -= [3]
            }.to change { array }.to_exclude(&:even?)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "fails if initial condition is not met by empty collection" do
          array = []
          expect {
            expect {
              array << 3
            }.to change { array }.to_exclude(&:even?)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "fails if final condition is not met" do
          array = [1,2,3]
          expect {
            expect {
              array -= [3]
            }.to change { array }.to_exclude(&:even?)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "fails if there is no change" do
          array = [2]
          expect {
            expect {
              # nop
            }.to change { array }.to_exclude(&:even?)
          }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
        end

        it "fails if also passed an item" do
          array = []
          expect {
            expect {
              # nop
            }.to change { array }.to_include(1, &:even?)
          }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
