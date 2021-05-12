json.extract! resume, :id, :category, :email, :address, :phone, :languages, :activities, :interests, :name, :default, :public, :industry, :template_name, :created_at, :updated_at
json.url resume_url(resume, format: :json)
