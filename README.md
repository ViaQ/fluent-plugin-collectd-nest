# Output filter plugin to rewrite Collectd JSON output to nest into a nested json

Rewrites the message coming from Collectd to store as a nested json. Can be used in Elasticsearch to display metrics.

## Installation

Use RubyGems:
If you use td-agent

    td-agent-gem install fluent-plugin-collectd-nest

If you use fluentd

    gem install fluent-plugin-collectd-nest

## Configuration

    <match pattern>
      type collectd_nest
    </match>

If the following record is passed:

```js
{"time":1000, "host":"host_v", "interval":5, "plugin":"plugin_v", "plugin_instance":"plugin_instance_v",
 "type":"type_v", "type_instance":"type_instance_v", "values":["v1", "v2"], "dsnames":["n1", "n2"],
 "dstypes":["t1", "t2"]}
```

then you get new record:

```js
{"host":"host_v",
 "collectd": {
   "time":1000, "interval":5, "plugin":"plugin_v", "plugin_instance":"plugin_instance_v",
   "type":"type_v", "type_instance":"type_instance_v", "dstypes":"t1",
   "plugin_v": {"type_v": {"n1":"v1", "n2":"v2"}}
 }
}
```

Empty values in "plugin", "plugin_instance", "type" or "type_instance" will not be copied into the new tag name

If a records has only one value like :
```js
{"time":1000, "host":"host_v", "interval":5, "plugin":"plugin_v", "plugin_instance":"plugin_instance_v",
 "type":"type_v", "type_instance":"type_instance_v", "values":["v1"], "dsnames":["n1"],
 "dstypes":["t1"]}
```
then the new record will be:

```js
{"host":"host_v",
 "collectd": {
   "time":1000, "interval":5, "plugin":"plugin_v", "plugin_instance":"plugin_instance_v",
   "type":"type_v", "type_instance":"type_instance_v", "dstypes":"t1",
   "plugin_v": {"type_v":"v1"}
 }
}
```

## WARNING

* This plugin was written to deal with a specific use-case, might not be the best fit for everyone. If you need more configurability/features, create a PR


## Copyright

<table>
  <tr>
    <td>Author</td><td> Viaq <TBD></td>
  </tr>
  <tr>
    <td>License</td><td>MIT License</td>
  </tr>
</table>
