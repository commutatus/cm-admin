module CmAdmin
  module ViewHelpers
    Dir[File.expand_path("view_helpers", __dir__) + "/*.rb"].each  { |f| require f }

    include PageInfoHelper
    include NavigationHelper
    include FormHelper
    include ColumnFieldHelper
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

    def manage_column_pop_up(klass)
      tag.div class: "modal fade form-modal table-column-modal", id: "columnActionModal", role: "dialog", aria: {labelledby: "exampleModalLabel"} do
        tag.div class: "modal-dialog", role: "document" do
          tag.div class: "modal-content" do
            tag.div do
              concat manage_column_header
              concat manage_column_body(klass)
              concat manage_column_footer
            end
          end
        end
      end
    end

    def manage_column_header
      tag.div class: "modal-header" do
        tag.button type: "button", class: "close", data: {dismiss: "modal"}, aria: {label: "Close"} do
          tag.span "X", aria: {hidden: "true"}
        end
        tag.h5 "Manage columns", class: "modal-title", id: "exampleModalLabel"
      end
    end

    def manage_column_body(klass)
      tag.div class: "modal-body" do
        tag.div class: "columns-list" do
          klass.available_fields[:index].each do |column_name|
            concat manage_column_body_list(column_name)
          end
        end
      end
    end

    def manage_column_body_list(column_name)
      tag.div class: "column-item" do
        concat manage_column_dragger(column_name.db_column_name)
        concat manage_column_item_name(column_name)
        concat manage_column_item_pointer(column_name.db_column_name)
      end
    end

    def manage_column_dragger(default_column_name)
      return if default_column_name == :id
      tag.div class: "dragger" do
        tag.i class: "fa fa-bars bolder"
      end
    end

    def manage_column_item_name(column_name)
      tag.div class: "column-item__name" do
        tag.p column_name.db_column_name.to_s.gsub('/', '_').humanize
      end
    end

    def manage_column_item_pointer(default_column_name)
      tag.div class: "column-item__action. #{"pointer" if default_column_name != :id} " do
        tag.i class: "fa #{default_column_name == :id ? "fa-lock" : "fa-times-circle"} bolder"
      end
    end

    def manage_column_footer
      tag.div class: "modal-footer" do
        tag.button type: "button", class: "gray-border-btn", data: {dismiss: "modal"} do
          "Close"
        end
        tag.button type: "button", class: "cta-btn" do
          "Save"
        end
      end
    end

  end
end
