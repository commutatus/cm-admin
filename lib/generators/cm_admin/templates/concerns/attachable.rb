module Attachable
  extend ActiveSupport::Concern

  included do
  end

  def save_with_attachments
    save!
    save_attachment
  end

  def update!(args)
    add_accessors_for_attachment_types
    super
    save_attachment
  end

  def initialize(args)
    add_accessors_for_attachment_types
    super
  end

  def save_attachment
    self.class.attachment_types.each do |attachment_type|
      next if send("#{attachment_type}_file").blank?

      arr = []
      if send("#{attachment_type}_file").class.eql?(Array)
        arr = send("#{attachment_type}_file")
      else
        arr << send("#{attachment_type}_file")
      end
      arr.each do |x|
        regexp = %r{\Adata:([-\w]+\/[-\w\+\.]+)?;base64,(.*)}m
        data_uri_parts = x[:content].match(regexp) || []
        decoded_data = Base64.decode64(data_uri_parts[2])
        filename = x[:filename]
        filepath = "#{Rails.root}/tmp/#{filename}"
        File.open(filepath, 'wb') do |f|
          f.write(decoded_data)
        end
        send(attachment_type.to_s).attach(io: File.open(filepath), filename: filename, content_type: data_uri_parts[1])
        File.delete(filepath)
      end
    end
  end

  def attached_url(attachment_type)
    if send(attachment_type.to_s).attached? && send(attachment_type.to_s).class == ActiveStorage::Attached::One
      Rails.application.routes.url_helpers.rails_blob_url(send(attachment_type.to_s))
    elsif send(attachment_type.to_s).attached? && send(attachment_type.to_s).class == ActiveStorage::Attached::Many
      send(attachment_type.to_s)
    end
  end

  private

    def add_accessors_for_attachment_types
      self.class.attachment_types.each do |attachment_type|
        singleton_class.class_eval { attr_accessor "#{attachment_type}_file" }
      end
    end
end