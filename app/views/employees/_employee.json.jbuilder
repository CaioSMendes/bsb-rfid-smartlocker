json.extract! employee, :id, :name, :lastname, :companyID, :phone, :function, :PIN, :pswdSmartlocker, :cardRFID, :status, :created_at, :updated_at
json.url employee_url(employee, format: :json)
