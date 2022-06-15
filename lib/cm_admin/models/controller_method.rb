module CmAdmin
  module Models
    module ControllerMethod
      extend ActiveSupport::Concern

      def show(params)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
        scoped_model = "CmAdmin::#{self.name}Policy::Scope".constantize.new(Current.user, self.name.constantize).resolve
        @ar_object = scoped_model.find(params[:id])
      end

      def index(params)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'index')
        # Based on the params the filter and pagination object to be set
        @ar_object = filter_by(params, nil, filter_params(params))
      end

      def new(params)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'new')
        @ar_object = @ar_model.new
      end

      def edit(params)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'edit')
        @ar_object = @ar_model.name.classify.constantize.find(params[:id])
      end

      def update(params)
        @ar_object = @ar_model.name.classify.constantize.find(params[:id])
        @ar_object.assign_attributes(resource_params(params))
        @ar_object
      end


      def create(params)
        @ar_object = @ar_model.name.classify.constantize.new(resource_params(params))
      end

      def filter_by(params, records, filter_params={}, sort_params={})
        filtered_result = OpenStruct.new
        sort_column = "created_at"
        sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
        sort_params = {sort_column: sort_column, sort_direction: sort_direction}
        
        records = "CmAdmin::#{self.name}Policy::Scope".constantize.new(Current.user, self.name.constantize).resolve if records.nil?
        records = records.order("#{current_action.sort_column} #{current_action.sort_direction}")

        final_data = CmAdmin::Models::Filter.filtered_data(filter_params, records, @filters)
        pagy, records = pagy(final_data)
        filtered_result.data = records
        filtered_result.pagy = pagy
        # filtered_result.facets = paginate(page, raw_data.size)
        # filtered_result.sort = sort_params
        # filtered_result.facets.sort = sort_params
        return filtered_result
      end

      def resource_params(params)
        permittable_fields = @permitted_fields || @ar_model.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym)
        permittable_fields += @ar_model.name.constantize.reflect_on_all_associations.map {|x|
          next if x.options[:polymorphic]
          if x.klass.name == "ActiveStorage::Attachment"
            if x.class.name.include?('HasOne')
              x.name
            elsif x.class.name.include?('HasMany')
              Hash[x.name.to_s, []]
            end
          elsif x.klass.name == "ActionText::RichText"
            x.name.to_s.gsub('rich_text_', '').to_sym
          end
        }.compact
        nested_tables = self.available_fields[:new].except(:fields).keys
        nested_tables += self.available_fields[:edit].except(:fields).keys
        nested_fields = nested_tables.uniq.map {|table|
          Hash[
            table.to_s + '_attributes',
            table.to_s.classify.constantize.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym) + [:id, :_destroy]
          ]
        }
        permittable_fields += nested_fields
        @ar_model.columns.map { |col| permittable_fields << col.name.split('_cents') if col.name.include?('_cents') }

        params.require(self.name.underscore.to_sym).permit(*permittable_fields)
      end
    end
  end
end
