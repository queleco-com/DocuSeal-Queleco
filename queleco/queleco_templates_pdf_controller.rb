# frozen_string_literal: true

# Quéleco : POST /api/templates/pdf dans l'édition libre de DocuSeal (AGPLv3), voir queleco/README.md.
module Api
  class QuelecoTemplatesPdfController < ApiBaseController
    MAX_PDF_SIZE = 20.megabytes
    MAX_DOCUMENTS = 10

    def create
      template = Template.new(account: current_account, author: current_user, source: :api,
                              name: params[:name].presence || 'Document',
                              folder: current_account.default_template_folder)
      authorize!(:create, template)

      files = uploaded_files
      return if performed?

      Templates.maybe_assign_access(template)
      Template.transaction do
        template.save!
        documents, = Templates::CreateAttachments.call(template, { files: }, extract_fields: true)
        template.fields = Templates::ProcessDocument.normalize_attachment_fields(template, documents)
        template.update!(schema: documents.map { |doc| { attachment_uuid: doc.uuid, name: doc.filename.base } })
      end

      WebhookUrls.enqueue_events(template, 'template.created')
      SearchEntries.enqueue_reindex(template)

      render json: Templates::SerializeForApi.call(template)
    rescue Templates::CreateAttachments::PdfEncrypted, Pdfium::PdfiumError
      render json: { error: 'PDF chiffré ou illisible' }, status: :unprocessable_content
    ensure
      files&.each { |file| file.tempfile.close! } if files.is_a?(Array)
    end

    private

    def uploaded_files
      documents = params[:documents]
      unless documents.is_a?(Array) && documents.size.between?(1, MAX_DOCUMENTS) && documents.all? { |d| d.respond_to?(:key?) }
        return error("documents : de 1 à #{MAX_DOCUMENTS} objets { name, file }")
      end
      if documents.any? { |d| d[:file].to_s.bytesize > (MAX_PDF_SIZE * 4 / 3) + 4 }
        return error('documents[].file : 20 Mo au plus')
      end

      files = []
      documents.each do |doc|
        data = Base64.strict_decode64(doc[:file].to_s)
        return error('documents[].file : PDF en base64 seulement') unless data.start_with?('%PDF-')

        tempfile = Tempfile.new(%w[document .pdf])
        tempfile.binmode.write(data)
        tempfile.rewind
        files << ActionDispatch::Http::UploadedFile.new(tempfile:, type: 'application/pdf',
                                                        filename: File.basename(doc[:name].presence || 'document.pdf'))
      end
      files
    rescue ArgumentError
      error('documents[].file : base64 invalide')
    ensure
      files&.each { |file| file.tempfile.close! } if performed?
    end

    def error(message)
      render json: { error: message }, status: :unprocessable_content
    end
  end
end
