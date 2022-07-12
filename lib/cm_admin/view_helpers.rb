module CmAdmin
  module ViewHelpers
    Dir[File.expand_path("view_helpers", __dir__) + "/*.rb"].each  { |f| require f }

    include ActionDropdownHelper
    include FieldDisplayHelper
    include FilterHelper
    include FormHelper
    include ManageColumnPopupHelper
    include NavigationHelper
    include PageInfoHelper

    # Included Rails view helper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::TagHelper

    def exportable(klass, html_class: [])
      tag.a "Export as excel", class: html_class.append("filter-btn modal-btn mr-2"), data: {toggle: "modal", target: "#exportmodal"} do
        concat tag.i class: 'fa fa-download'
        concat tag.span " Export"
      end
    end

    def column_pop_up(klass, required_filters = nil)
      tag.div class: "modal fade form-modal", id: "exportmodal", role: "dialog", aria: {labelledby: "exportModal"} do
        tag.div class: "modal-dialog modal-lg", role: "document" do
          tag.div class: "modal-content" do
            concat pop_ups(klass, required_filters)
          end
        end
      end
    end

    def pop_ups(klass, required_filters)
      tag.div do
        concat pop_up_header
        concat pop_up_body(klass, required_filters)
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

    def pop_up_body(klass, required_filters)
      tag.div class: "modal-body" do
        form_tag '/cm_admin/export_to_file.js', id: 'export-to-file-form', style: "width: 100%;", class:"cm-admin-csv-export-form" do
          concat hidden_field_tag 'class_name', klass.name.to_s, id: 'export-to-file-klass'
          concat checkbox_row(klass)
          concat tag.hr
          concat submit_tag 'Export', class: 'btn btn-primary btn-bordered export-to-file-btn'
        end
      end
    end

    def checkbox_row(klass)
      tag.div class: "row" do
        CmAdmin::Models::Export.exportable_columns(klass).each do |column_path|
          concat create_checkbox(column_path)
        end
      end
    end

    def create_checkbox(column_path)
      tag.div class: "col-md-4" do
        concat check_box_tag "columns[]", column_path, id: column_path.to_s.gsub('/', '-')
        concat " " + column_path.to_s.gsub('/', '_').humanize
      end
    end
  end
end
