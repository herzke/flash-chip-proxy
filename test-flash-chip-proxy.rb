require_relative "flash-chip-proxy"
require "test/unit"

class TestFlashChipProxy < Test::Unit::TestCase

  def test_operating_modes()
    # the FlashChipProxy can be in modes :learn or :replace

    # Default is :replace
    assert_equal(:replace, FlashChipProxy.new().mode() )

    # Mode :learn has to be enabled
    p = FlashChipProxy.new()
    p.mode = :learn
    assert_equal(:learn, p.mode())

    # We cannot assign arbitrary modes
    assert_raise(RuntimeError){p.mode = :hello}
  end

  def test_storage_directory()
    # The default storage directory is the cwd "."
    assert_equal(".", FlashChipProxy.new().storage_directory())

    # storage directory can be set with constructor parameter
    assert_equal("/tmp", FlashChipProxy.new("/tmp").storage_directory())

    # storage directory must exist
    assert_raise(RuntimeError){FlashChipProxy.new("/doesnotexist")}
  end
  
end
