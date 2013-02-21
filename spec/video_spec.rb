require File.expand_path('../spec_helper', __FILE__)
require 'helix'

describe Helix::Video do

  def import_xml(values={})
    { list: { entry: values[:url_params] || {} } }.to_xml(root: :add)
  end

  let(:klass)             { Helix::Video }
  subject                 { klass }
  its(:guid_name)         { should eq('video_id') }
  its(:resource_label_sym)    { should be(:video)   }
  its(:plural_resource_label) { should eq('videos') }
  [:find, :create, :all, :find_all, :where].each do |crud_call|
    it { should respond_to(crud_call) }
  end

  describe "Constants"

  ### INSTANCE METHODS

  describe "an instance" do
    let(:obj)            { klass.new({video_id: 'some_video_guid'}) }
    subject              { obj }
    its(:resource_label_sym) { should be(:video) }

    describe "#download" do
      let(:meth)        { :download }
      let(:mock_config) { mock(Helix::Config, build_url: :the_built_url, signature: :some_sig) }
      subject      { obj.method(meth) }
      let(:params) { { params: {signature: :some_sig } } }
      before do
        obj.stub(:config)            { mock_config }
        obj.stub(:guid)              { :some_guid  }
        obj.stub(:plural_resource_label) { :resource_label }
        RestClient.stub(:get) { '' }
      end
      { '' => '', mp3: :mp3, nil => '' }.each do |arg,actual|
        build_url_h = {action: :file, content_type: actual, guid: :some_guid, resource_label: :resource_label}
        context "when given {content_type: #{arg}" do
          it "should build_url(#{build_url_h})" do
            mock_config.should_receive(:build_url).with(build_url_h)
            obj.send(meth, content_type: arg)
          end
          it "should get a view signature" do
            mock_config.should_receive(:signature).with(:view) { :some_sig }
            obj.send(meth, content_type: arg)
          end
          it "should return an HTTP get to the built URL with the view sig" do
            mock_config.stub(:build_url).with(build_url_h) { :the_url }
            RestClient.should_receive(:get).with(:the_url, params) { :expected }
            expect(obj.send(meth, content_type: arg)).to be(:expected)
          end
        end
      end
    end

    describe "#play" do
      let(:meth)        { :play }
      let(:mock_config) { mock(Helix::Config, build_url: :the_built_url, signature: :some_sig) }
      subject      { obj.method(meth) }
      let(:params) { { params: {signature: :some_sig } } }
      before do
        obj.stub(:config)            { mock_config }
        obj.stub(:guid)              { :some_guid  }
        obj.stub(:plural_resource_label) { :resource_label }
        RestClient.stub(:get) { '' }
      end
      { '' => '', mp3: :mp3, nil => '' }.each do |arg,actual|
        build_url_h = {action: :play, content_type: actual, guid: :some_guid, resource_label: :resource_label}
        context "when given {content_type: #{arg}" do
          it "should build_url(#{build_url_h})" do
            mock_config.should_receive(:build_url).with(build_url_h)
            obj.send(meth, content_type: arg)
          end
          it "should get a view signature" do
            mock_config.should_receive(:signature).with(:view) { :some_sig }
            obj.send(meth, content_type: arg)
          end
          it "should return an HTTP get to the built URL with the view sig" do
            mock_config.stub(:build_url).with(build_url_h) { :the_url }
            RestClient.should_receive(:get).with(:the_url, params) { :expected }
            expect(obj.send(meth, content_type: arg)).to be(:expected)
          end
        end
      end
    end

    describe "#stillframe" do
      let(:meth)        { :stillframe }
      let(:mock_config) { mock(Helix::Config) }
      subject           { obj.method(meth) }
      its(:arity)       { should eq(-1) }
      it "should call self.class.get_stillframe" do
        obj.stub(:guid) { :some_guid }
        klass.should_receive(:get_stillframe)
        obj.send(meth)
      end
    end

    [:destroy, :update].each do |crud_call|
      it { should respond_to(crud_call) }
    end

  end

  ### CLASS METHODS

  describe ".slice" do
    let(:meth)        { :slice }
    let(:mock_config) { mock(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-1) }
    let(:params)      { { params:       { signature: :some_sig },
                          content_type: "text/xml" } }
    let(:url_opts)    { { action:         :slice,
                          resource_label: "videos",
                          content_type:   :xml,
                          formats:        :some_format } }
    let(:sig_opts)    { { contributor:  :helix,
                          library_id:   :development,
                          formats:      :some_format } }
    before            { Helix::Config.stub(:instance) { mock_config } }

    it "should get an ingest signature" do
      mock_config.should_receive(:build_url).with(url_opts)
      mock_config.should_receive(:signature).with(:ingest, sig_opts) { :some_sig }
      RestClient.should_receive(:post).with(nil, import_xml, params)
      klass.send(meth, {formats: :some_format})
    end
  end

  describe ".get_stillframe" do
    let(:meth)        { :get_stillframe }
    let(:mock_config) { mock(Helix::Config) }
    subject           { klass.method(meth) }
    its(:arity)       { should eq(-2) }
    let(:image_data)  { :some_image_data }
    let(:guid)        { :some_guid }
    let(:server)      { "service-staging" }
    let(:base_url)    { "#{server}.twistage.com/videos/#{guid}/screenshots/" }
    context "when no height or width is passed in " do
      let(:full_url) { "#{base_url}original.jpg" }
      it "should build the correct url and return data" do
        RestClient.should_receive(:get).with(full_url) { image_data }
        expect(klass.send(meth, guid)).to eq(image_data)
      end
    end
    [:height, :width].each do |dimension|
      context "when #{dimension} is passed in" do
        url_tag = (dimension == :height ? "h" : "w")
        let(:dim_val)   { 100 }
        let(:full_url)  { "#{base_url}#{dim_val}#{url_tag}.jpg" }
        let(:opts)      { { dimension => dim_val } }
        it "should clone the opts arg" do
          RestClient.stub(:get).with(full_url) { image_data }
          opts.should_receive(:clone) { opts }
          klass.send(meth, guid, opts)
        end
        it "should build the correct url and return data" do
          RestClient.should_receive(:get).with(full_url) { image_data }
          expect(klass.send(meth, guid, opts)).to eq(image_data)
        end
      end
    end
    context "when both height and width are passed in" do
      let(:dim_val)   { 100 }
      let(:full_url)  { "#{base_url}#{dim_val}w#{dim_val}h.jpg" }
      let(:opts)      { { height: dim_val, width: dim_val } }
      it "should clone the opts arg" do
        RestClient.stub(:get).with(full_url) { image_data }
        opts.should_receive(:clone) { opts }
        klass.send(meth, guid, opts)
      end
      it "should build the correct url and return data" do
        RestClient.should_receive(:get).with(full_url) { image_data }
        expect(klass.send(meth, guid, opts)).to eq(image_data)
      end
    end
  end
end
