module CmAdmin
  module ViewHelpers
    module ExportHelper
      # Email is now added as default. Pop the textbox during column select
      # If no email is provided, it takes a admin email provided during setup
      # Raises error if admin email is also not present. Exception to be written
      def exportable(html_class: [], email = nil)
        tag.a "Export as excel", class: html_class.append("filter-btn modal-btn mr-2"), data: {toggle: "modal", target: "#exportmodal"} do
          concat tag.i class: 'fa fa-download'
          concat tag.span " Excel"
        end
      end

      def column_pop_up(email, required_filters = nil)
        tag.div class: "modal fade", id: "exportmodal", tabindex: "-1", role: "dialog", aria: {labelledby: "exportModal"} do
          tag.div class: "modal-dialog modal-lg", role: "document" do
            tag.div class: "modal-content" do
              concat pop_ups(email, required_filters)
            end
          end
        end
      end

      def pop_ups(email, required_filters)
        tag.div do
          concat pop_up_header
          concat pop_up_body(email, required_filters)
        end
      end

      def pop_up_header
        tag.div class: "modal-header" do
          tag.button type: "button", class: "close", data: {dismiss: "modal"}, aria: {label: "Close"} do
            tag.span "X", aria: {hidden: "true"}
          end
          tag.h4 "Select columns to export", class: "modal-title", id: "exportModal"
        end
      end

      def pop_up_body(email, required_filters)
        tag.div class: "modal-body" do
          form_tag "/admin/#{@model.ar_model.name.underscore.pluralize}/export", id: 'export-to-file-form', style: "width: 100%;", class:"spotlight-csv-export-form" do
            concat hidden_field_tag 'email', email, id: 'export-to-file-email'
            concat hidden_field_tag 'class_name', @model.ar_model.name.to_s, id: 'export-to-file-klass'
            # filters_to_post_helper(required_filters) if required_filters
            # params_to_post_helper(filters: controller.filter_params) if controller.filter_params
            # params_to_post_helper(sort: controller.sort_params) if controller.sort_params
            # case SpotlightSearch.exportable_columns_version
            # when :v1
              concat checkbox_row
            # when :v2
            #   concat checkbox_row_v2(klass)
            # end
            concat tag.hr
            concat submit_tag 'Export as excel', class: 'btn btn-primary btn-bordered export-to-file-btn'
          end
        end
      end

      def checkbox_row
        tag.div class: "row" do
          @model.available_fields[:export].map { |i| i[:field_name] }.each do |column_name|
            concat create_checkbox(column_name)
          end
        end
      end

      def create_checkbox(column_name)
        tag.div class: "col-md-4" do
          concat check_box_tag "columns[]", column_name.to_s
          concat column_name.to_s.humanize
        end
      end
    end
  end
end
