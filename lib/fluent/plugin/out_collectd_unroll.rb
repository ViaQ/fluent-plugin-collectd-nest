module Fluent
  class CollectdUnrollOutput < Output
    Fluent::Plugin.register_output('collectd_unroll', self)

    config_param :remove_tag_prefix,  :string, :default => nil
    config_param :add_tag_prefix,     :string, :default => nil


    def emit(tag, es, chain)
      es.each { |time, record|
        tag = update_tag(tag, record)
        Engine.emit(tag, time, normalize_record(record))
      }

      chain.next
    end


    def update_tag(tag, record)
      if remove_tag_prefix
        if remove_tag_prefix == tag
          tag = ''
        elsif tag.to_s.start_with?(remove_tag_prefix+'.')
          tag = tag[remove_tag_prefix.length+1 .. -1]
        end
      end
      if add_tag_prefix
          tag = "#{add_tag_prefix}.#{record['plugin']}.#{record['type']}"
      end
      return tag
    end

    private

    def normalize_record(record)
      if record.nil?
        return record
      end
      if !(record.has_key?('values')) || !(record.has_key?('dsnames')) || !(record.has_key?('dstypes')) || !(record.has_key?('host')) || !(record.has_key?('plugin')) || !(record.has_key?('plugin_instance')) || !(record.has_key?('type')) || !(record.has_key?('type_instance'))
        return record
      end
      rec_plugin = record['plugin']
      rec_type = record['type']
      record[rec_plugin] = {rec_type => {}}

      record['values'].each_with_index { |value, index|
        record[rec_plugin][rec_type][record['dsnames'][index]] = value
      }
      record['dstypes'] = record['dstypes'][0]
      record.delete('dstypes')
      record.delete('dsnames')
      record.delete('values')
      record
    end
  end
end
