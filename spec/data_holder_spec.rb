require "#{File.dirname(__FILE__)}/../lib/data_holder"
describe DataHolder do
  before :each do
    @results = DataHolder.new("SUM")
  end

  it "should be allocated" do
    foo = DataHolderC.new(5)
  end

  it "should allow datapoints to be added" do
    data_add = lambda do
      @results.add_datapoint(:instant => 1234, :group => "somegroup")
    end
    data_add.should_not raise_error
  end

  it "should raise an error when not given a instant" do
    lambda do
      @results.add_datapoint({:group => "tada"})
    end.should raise_error(ArgumentError)

    lambda do
      @results.add_datapoint({:instant => 131241})
    end.should raise_error(ArgumentError)
  end

  it "should return a hash that is seperated by group" do
    [{:instant => 1, :group => "yup", :value => 1},
     {:instant => 3, :group => "yup", :value => 1},
     {:instant => 2, :group => "yup", :value => 1}].each do |opts|
        @results.add_datapoint(opts)
      end
    @results.to_hash.should == {
      1 => {"yup" => 1},
      2 => {"yup" => 1},
      3 => {"yup" => 1}
    }
  end

  it "should have the groups" do
    [{:instant => 1, :group => "foo"},
     {:instant => 2, :group => "bar"}].each do |opts|
      @results.add_datapoint(opts)
    end
    @results.groups.should == ["foo", "bar"]
  end

  it "should only normalize once" do
    [{:instant => 1, :group => "yup", :value => 1},
     {:instant => 3, :group => "yup", :value => 1},
     {:instant => 2, :group => "yup", :value => 1}].each do |opts|
        @results.add_datapoint(opts)
      end
    @results.normalize(10)
    @results.to_hash.should == {
      1 => {"yup" => 10},
      2 => {"yup" => 10},
      3 => {"yup" => 10}
    }
    @results.normalize(200)
    @results.to_hash.should == {
      1 => {"yup" => 10},
      2 => {"yup" => 10},
      3 => {"yup" => 10}
    }
  end

  it "should give back traffic independent results" do
    results = DataHolder.new("SUM")
    sample_data.each {|opts| results.add_datapoint(opts) }
    traffic_ind_array = results.make_traffic_independent.to_hash[1].map {|x| x[1].to_f }
    [0.016983016983016..0.016983016983018, 0.010989010989010..0.010989010989012, 0.015984015984015..0.015984015984017, 0.000999000999000998..0.000999000999001000, 0.014985014985014..0.014985014985016, 0.013986013986013..0.013986013986015, 0.012987012987012..0.012987012987014, 0.011988011988011..0.011988011988013, 0.018981018981018..0.018981018981020, 0.017982017982017..0.017982017982019, 0.01998001998001..0.01998001998003].each_with_index do |float, index|
      float.should include(traffic_ind_array[index])
    end
  end
end

def sample_data
  [
    {:instant => 1, :group => "yup", :value => 20, :count => 1},
    {:instant => 1, :group => "yup2", :value => 19, :count => 100},
    {:instant => 1, :group => "yup3", :value => 18, :count => 100},
    {:instant => 1, :group => "yup4", :value => 17, :count => 100},
    {:instant => 1, :group => "yup5", :value => 16, :count => 100},
    {:instant => 1, :group => "yup6", :value => 15, :count => 100},
    {:instant => 1, :group => "yup7", :value => 14, :count => 100},
    {:instant => 1, :group => "yup8", :value => 13, :count => 100},
    {:instant => 1, :group => "yup9", :value => 12, :count => 100},
    {:instant => 1, :group => "yup10", :value => 11, :count => 100},
    {:instant => 1, :group => "yup11", :value => 1, :count => 100}
  ]
end
