module Fluent
  class CollectdNestOutput < Output
    Fluent::Plugin.register_output('collectd_nest', self)

    config_param :remove_tag_prefix,  :string, :default => nil
    config_param :add_tag_prefix,     :string, :default => nil


    def emit(tag, es, chain)
      tag = update_tag(tag)
      es.each { |time, record|
        Engine.emit(tag, time, normalize_record(record))
      }

      chain.next
    end


    def update_tag(tag)
      if remove_tag_prefix
        if remove_tag_prefix == tag
          tag = ''
        elsif tag.to_s.start_with?(remove_tag_prefix+'.')
          tag = tag[remove_tag_prefix.length+1 .. -1]
        end
      end
      if add_tag_prefix
        tag = tag && tag.length > 0 ? "#{add_tag_prefix}.#{tag}" : add_tag_prefix
      end
      return tag
    end

    private

    def normalize_record(record)
      if record.nil?
        return record
      end
      if !(record.has_key?('values')) || !(record.has_key?('dsnames')) || !(record.has_key?('dstypes')) || !(record.has_key?('host')) || !(record.has_key?('plugin')) || !(record.has_key?('type'))
        return record
      end
      new_rec = {}
      new_rec['hostname']= record['host']
      rec_plugin = record['plugin']
      rec_type = record['type']
      record[rec_plugin] = {rec_type => {}}

      record['values'].each_with_index { |value, index|
        record[rec_plugin][rec_type][record['dsnames'][index]] = value
      }
      record['dstypes'] = record['dstypes'].uniq
      record.delete('host')
      record.delete('dsnames')
      record.delete('values')
      new_rec['collectd']= record
      new_rec
    end
  end
end

