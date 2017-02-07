require 'fluent/test'
require 'fluent/plugin/out_collectd_unroll'


class CollectdUnrollOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
    type collectd_unroll
    tag foo.filtered
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::OutputTestDriver.new(Fluent::CollectdUnrollOutput, tag='test_tag').configure(conf)
  end

  def test_rewrite_tag
    d = create_driver %[
      type collectd_unroll
      add_tag_prefix test_tag
    ]

    d.run do
      d.emit({
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin1', "plugin_instance" => 'plugin_instance',
        "type" => 'type1', "type_instance" => 'type_instance',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      })
      d.emit({
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin2', "plugin_instance" => '',
        "type" => 'type2', "type_instance" => 'type_instance',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      })
      d.emit({
        "time" => 1000, "host" => 'host', "interval" => 5,
        "plugin" => 'plugin3', "plugin_instance" => 'plugin_instance',
        "type" => 'type3', "type_instance" => 'type_instance',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      })
    end

    assert_equal 3, d.emits.length
    assert_equal "test_tag.plugin1.type1", d.emits[0][0]
    assert_equal "test_tag.plugin2.type2", d.emits[1][0]
    assert_equal "test_tag.plugin3.type3", d.emits[2][0]
  end

  def test_normalize_record
    d = create_driver %[
      type collectd_unroll
    ]

    d.run do
      d.emit({
        "time" => 1000, "host" => 'host_v', "interval" => 5,
        "plugin" => 'plugin_v', "plugin_instance" => 'plugin_instance_v',
        "type" => 'type_v', "type_instance" => 'type_instance_v',
        "values" => ['v1', 'v2'], "dsnames" => ['n1', 'n2'], "dstypes" => ['t1', 't2']
      })
    end

    assert_equal d.records[0][:collectd]['plugin_v']['type_v']['n1'], 'v1'
    assert_equal d.records[0][:collectd]['plugin_v']['type_v']['n2'], 'v2'
    assert_equal d.records[0][:collectd].has_key?('host'), false
    assert_equal d.records[0][:collectd]['plugin'], 'plugin_v'
    assert_equal d.records[0][:collectd]['type'], 'type_v'
    assert_equal d.records[0][:collectd]['plugin_instance'], 'plugin_instance_v'
    assert_equal d.records[0][:collectd]['type_instance'], 'type_instance_v'
    assert_equal d.records[0][:collectd]['dstypes'], 't1'

  end

end
