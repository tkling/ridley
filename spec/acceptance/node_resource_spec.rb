require 'spec_helper'

describe "Node API operations", type: "acceptance" do
  let(:server_url) { "https://api.opscode.com" }
  let(:client_name) { "reset" }
  let(:client_key) { "/Users/reset/.chef/reset.pem" }
  let(:organization) { "vialstudios" }

  let(:connection) do
    Ridley.connection(
      server_url: server_url,
      client_name: client_name,
      client_key: client_key,
      organization: organization
    )
  end

  before(:all) { WebMock.allow_net_connect! }
  after(:all) { WebMock.disable_net_connect! }

  before(:each) do
    connection.node.delete_all
  end

  describe "finding a node" do
    let(:target) do
      Ridley::Node.new(
        connection,
        name: "ridley-one"
      )
    end

    before(:each) do
      connection.node.create(target)
    end

    it "returns a Ridley::Node object" do
      connection.node.find(target.name).should eql(target)
    end
  end

  describe "creating a node" do
    let(:target) do
      Ridley::Node.new(
        connection,
        name: "ridley-one"
      )
    end
    
    it "returns a new Ridley::Node object" do
      connection.node.create(target).should eql(target)
    end

    it "adds a new node to the server" do
      connection.start do
        node.create(target)

        node.all.should have(1).node
      end
    end
  end

  describe "deleting a node" do
    let(:target) do
      Ridley::Node.new(
        connection,
        name: "ridley-one"
      )
    end

    before(:each) do
      connection.node.create(target)
    end

    it "returns the deleted object" do
      connection.start do
        node.delete(target).should eql(target)
      end
    end

    it "removes the node from the server" do
      connection.start do
        node.delete(target)

        node.find(target).should be_nil
      end
    end
  end

  describe "deleting all nodes" do
    it "deletes all nodes from the remote server" do
      connection.start do
        node.delete_all

        connection.node.all.should have(0).nodes
      end
    end
  end

  describe "listing all nodes" do
    before(:each) do
      connection.start do
        node.create(name: "ridley-one")
        node.create(name: "ridley-two")
      end
    end

    it "returns an array of Ridley::Node objects" do
      connection.start do
        obj = node.all
        
        obj.should each be_a(Ridley::Node)
        obj.should have(2).nodes
      end
    end
  end

  describe "updating a node" do
    let(:target) do
      Ridley::Node.new(
        connection,
        name: "ridley-one"
      )
    end

    before(:each) do
      connection.node.create(target)
    end

    it "returns the updated node" do
      connection.node.update(target).should eql(target)
    end

    it "saves a new set of 'normal' attributes" do
      target.normal = normal = {
        attribute_one: "value_one",
        nested: {
          other: "val"
        }
      }

      connection.start do
        node.update(target)
        obj = node.find(target)

        obj.normal.should eql(normal)
      end
    end

    it "saves a new set of 'default' attributes" do
      target.default = defaults = {
        attribute_one: "val_one",
        nested: {
          other: "val"
        }
      }

      connection.start do
        node.update(target)
        obj = node.find(target)

        obj.default.should eql(defaults)
      end
    end

    it "saves a new set of 'automatic' attributes" do
      target.automatic = automatics = {
        attribute_one: "val_one",
        nested: {
          other: "val"
        }
      }

      connection.start do
        node.update(target)
        obj = node.find(target)

        obj.automatic.should eql(automatics)
      end
    end

    it "saves a new set of 'override' attributes" do
      target.override = overrides = {
        attribute_one: "val_one",
        nested: {
          other: "val"
        }
      }

      connection.start do
        node.update(target)
        obj = node.find(target)

        obj.override.should eql(overrides)
      end
    end

    it "places a node in a new 'chef_environment'" do
      target.chef_environment = environment = "ridley"

      connection.start do
        node.update(target)
        obj = node.find(target)

        obj.chef_environment.should eql(environment)
      end
    end

    it "saves a new 'run_list' for the node" do
      target.run_list = run_list = ["recipe[one]", "recipe[two]"]

      connection.start do
        node.update(target)
        obj = node.find(target)

        obj.run_list.should eql(run_list)
      end
    end
  end
end
