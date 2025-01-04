module ApplicationHelper
    def format_datetime(datetime_string)
        return unless datetime_string
    
        datetime = Time.parse(datetime_string)
        datetime.strftime('%d/%m/%Y %H:%M:%S')
      rescue ArgumentError
        'Invalid datetime format'
    end
end
