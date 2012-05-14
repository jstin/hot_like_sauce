# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "HotLikeSauce" do

  describe "obscures text and strings" do

    before :each do
      Object.send(:remove_const, :Post) if defined?(Post)
      Object.send(:remove_const, :Grape) if defined?(Grape)
      class Post < ActiveRecord::Base
        attr_obscurable :title
      end

      class Grape < ActiveRecord::Base
        attr_obscurable :title, :contents
      end
    end

    it "can obscure fields to the datatbase" do
      p = Post.new
      p.title = "raison brain"
      p.save
      p.reload
      p.title.should == "raison brain"

      Object.send(:remove_const, :Post)
      class Post < ActiveRecord::Base

      end

      p = Post.find p.id
      p.title.should_not == "raison brain"
    end

    it "can only obscure the fields specified" do
      p = Post.new
      p.body = "water is tasty and wonderful"
      p.save

      Object.send(:remove_const, :Post)
      class Post < ActiveRecord::Base

      end

      p = Post.find p.id
      p.body.should == "water is tasty and wonderful"
    end

    it "can obscure fields on read" do
      p = Post.new
      p.title = "we all belong"
      p.save
      p.reload

      Post.obscure_read_on_fields!
      p.title.should_not == "we all belong"

      Post.unobscure_read_on_fields!

      p.title.should == "we all belong"
    end

    it "can obscure fields on read by default" do
      Object.send(:remove_const, :Post)
      class Post < ActiveRecord::Base
        attr_obscurable :title, :obscure_on_read => true
      end

      p = Post.new
      p.title = "we all belong"
      p.save
      p.reload

      p.title.should_not == "we all belong"
    end

    it "can obscure individual fields on read" do
      p = Grape.new
      p.title = "i'm the doctor dawg"
      p.contents = "who are you to be yourself?"
      p.save
      p.reload

      Post.obscure_read_on_fields!(:contents)
      p.title.should == "i'm the doctor dawg"
      p.reload
      p.contents.should == "who are you to be yourself?"

      Grape.obscure_read_on_fields!(:contents)
      p.title.should == "i'm the doctor dawg"
      p.contents.should_not == "who are you to be yourself?"

      Grape.unobscure_read_on_fields!(:contents)
      p.title.should == "i'm the doctor dawg"
      p.contents.should == "who are you to be yourself?"
    end

    it "can obscure optionally have an unobscured accessor" do
      g = Grape.create :title => "i'm the doctor dawg"

      g.respond_to?(:unobscured_title).should == false

      Object.send(:remove_const, :Grape) if defined?(Grape)
      class Grape < ActiveRecord::Base
        attr_obscurable :title, :contents, :unobscured_accessor => true
      end

      g = Grape.find g.id
      g.unobscured_title.should == "i'm the doctor dawg"
    end

    it "can obscure special charaters" do
     g = Grape.create(:contents => "!@$%^&*()\n")
     g.contents.should == "!@$%^&*()\n"
    end

    it "can obscure non-latin-1 characters" do
     g = Grape.create(:contents => "áéîóü")
     g.contents.should == "áéîóü"
    end

    it "can obscure empty strings" do
     g = Grape.create(:contents => "")
     g.contents.should == ""
    end

  end

  describe "validates proper fields" do

    before :each do
      Object.send(:remove_const, :Post) if defined?(Post)
      Object.send(:remove_const, :Grape) if defined?(Grape)
      class Post < ActiveRecord::Base
        attr_obscurable :title
      end

      class Grape < ActiveRecord::Base
        attr_obscurable :title
      end
    end

    it "can not obscure integer fields" do
      expect { Grape.attr_obscurable(:vineyard_id) }.should raise_exception
    end

    it "can not obscure datetime fields" do
      expect { Grape.attr_obscurable(:created_at) }.should raise_exception
    end

  end

end
