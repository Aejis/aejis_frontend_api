module FrontendApi
  class DatasetFilter
    LIMIT = 40

    class << self
      def filters
        @filters ||= {}
      end

    private

      def filter(key, &block)
        filters[key] = block
      end

      def inherited(sub)
        sub.instance_variable_set(:@filters, filters.dup)
      end
    end

    filter(:limit) { |ds, limit| ds.limit([limit.to_i, self.class::LIMIT].find(&:positive?)) }
    filter(:offset) { |ds, offset| ds.offset(offset.to_i) }
    filter(:sort) do |ds, sort|
      sort = sort.to_sym
      next ds unless ds.columns.include?(sort)

      params[:dir] == 'desc' ? ds.order(Sequel.desc(sort)) : ds.order(Sequel.asc(sort))
    end
    filter(:dir) { |ds, _| ds } # for documentation purposes
    filter(:required_id) do |ds, required_id|
      required_id = Array(required_id).map(&:to_i)
      ds.union(ds.model.where(id: required_id))
    end

    # default implementation
    def filter(ds)
      ds = ds.offset(0).limit(self.class::LIMIT) # default limit/offset values
      apply_filters(ds)
        .order_append(Sequel.desc(:id)) # default ordering
    end

  private

    def initialize(params)
      @params = params
    end

    attr_reader :params

    # apply all filter defined with DatasetFilter.filter
    def apply_filters(dataset)
      fltrs = self.class.filters
      fltrs[:required_id] = fltrs.delete(:required_id)
      fltrs.reduce(dataset) do |ds, (key, block)|
        params.key?(key) ? block.call(ds, params[key], params) : ds
      end
    end
  end
end
