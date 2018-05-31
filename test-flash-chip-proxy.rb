require_relative "flash-chip-proxy"
require "test/unit"

class TestFlashChipProxy < Test::Unit::TestCase

  def test_operating_modes()
    # the FlashChipProxy can be in modes :learn or :replace

    # Default is :replace
    assert_equal(:replace, FlashChipProxySettings.new().mode() )

    # Mode :learn has to be enabled
    p = FlashChipProxySettings.new()
    p.mode = :learn
    assert_equal(:learn, p.mode())

    # We cannot assign arbitrary modes
    assert_raise(RuntimeError){p.mode = :hello}
  end

  def test_storage_directory()
    # The default storage directory is the cwd "."
    assert_equal(".", FlashChipProxySettings.new().storage_directory())

    # storage directory can be set with constructor parameter
    assert_equal("/tmp", FlashChipProxySettings.new("/tmp").storage_directory())

    # storage directory must exist
    assert_raise(RuntimeError){FlashChipProxySettings.new("/doesnotexist")}
  end

  def test_port_opens
    # the proxy by default opens port 8880
    assert_equal(8880, FlashChipProxySettings.new().port())

    # but can be configured to open a different port
    assert_equal(8881, FlashChipProxySettings.new(".",8881).port())

    # test if the port actually opens)
    p = FlashChipProxy.new(".",8882)
    assert_true(system("netstat -tln | grep -q 0.0.0.0:8882.*LISTEN"))
  end
    
end
