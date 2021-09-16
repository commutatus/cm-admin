module CmAdmin
  module Models
    module ControllerMethod
      extend ActiveSupport::Concern

      def show(params)
        @current_action = CmAdmin::Models::Action.find_by(self, name: 'show')
        @ar_object = @ar_model.find(params[:id])
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
        @ar_object = @ar_model.find(params[:id])
      end
  
      def update(params)
        @ar_object = @ar_model.find(params[:id])
        @ar_object.assign_attributes(resource_params(params))
        @ar_object
      end
  
      def create(params)
        @ar_object = @ar_model.new(resource_params(params))
      end

      def filter_by(params, records, filter_params={}, sort_params={})
        filtered_result = OpenStruct.new
        sort_column = "created_at"
        sort_direction = %w[asc desc].include?(sort_params[:sort_direction]) ? sort_params[:sort_direction] : "asc"
        sort_params = {sort_column: sort_column, sort_direction: sort_direction}
        records = self.name.constantize.where(nil) if records.nil?
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
        permittable_fields += @ar_model.reflect_on_all_attachments.map {|x|
          if x.class.name.include?('HasOne')
            x.name
          elsif x.class.name.include?('HasMany')
            Hash[x.name.to_s, []]
          end
        }.compact
        nested_tables = self.available_fields[:new].except(:fields).keys
        nested_tables += self.available_fields[:edit].except(:fields).keys
        nested_fields = nested_tables.map {|table|
          Hash[
            table.to_s + '_attributes',
            table.to_s.singularize.titleize.constantize.columns.map(&:name).reject { |i| CmAdmin::REJECTABLE_FIELDS.include?(i) }.map(&:to_sym) + [:id, :_destroy]
          ]
        }
        permittable_fields += nested_fields
        params.require(self.name.underscore.to_sym).permit(*permittable_fields)
      end
    end
  end
end