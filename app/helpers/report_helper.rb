module ReportHelper 
  def generate_report
    begin
      user_id = params[:user_id]
      user = User.find(user_id)
      
      if user.nil?
        error!('User not found', 404)
      else
        ExportCsvJob.perform_async(user_id)
        { message: 'Report generation started. You can download it when it is complete.' }
      end
    rescue => e
      error!("An error occurred while processing your request: #{e.message}", 500)
    end
  end

  def download_report
    begin
      user_id = params[:user_id]
      file_path = Rails.root.join('public', "restaurants_#{user_id}-#{Date.current}.csv")
      # if File.exist?(file_path)
        send_file(file_path, type: 'text/csv', filename: "restaurants_#{user_id}-#{Date.current}.csv", disposition: 'attachment')
        File.delete(file_path) if File.exist?(file_path)
      # else
      #   { message: 'Report file not found. Please generate the report first.' }
      # end
    rescue => e
      { message: "An error occurred while processing your request: #{e.message}" }
    end
  end
  
end