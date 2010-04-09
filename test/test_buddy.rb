require 'test/unit'
require 'mocha'

class BuddyTests < Test::Unit::TestCase
  def test_user_getinfo
    result = [{"first_name"=>"Ole", "name"=>"Foo Bar", "uid"=>123456789}]

    Buddy::Service.expects(:call).with('Users.getInfo', {:uids => '686373959', :fields => 'uid, name, first_name'}).returns(result)
  end
end
