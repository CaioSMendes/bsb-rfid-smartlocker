Rails.application.routes.draw do
  get 'debug_logs/index'
  get 'email_settings/new'
  get 'email_settings/create'
  get 'static_pages/inadimplente'
  root 'welcome#index'
  get 'admin', to: 'admin#index'
  get 'dadosuser', to: 'admin#dadosuser'
  get '/manager_users', to: 'manager_users#index', as: 'manager_users_index'
  get 'inadimplente', to: 'static_pages#inadimplente'
  get 'keylockers/:id/generate_qr', to: 'keylockers#generate_qr', as: 'generate_qr_keylocker'
  get 'access_auth', to: 'access_auth#index'
  post 'access_auth/verify', to: 'access_auth#verify'
  get 'access_auth/success_page', to: 'access_auth#success_page'
  post 'access_auth/success_page', to: 'access_auth#success_page'
  get 'confirm_pin', to: 'access_auth#confirm_pin', as: 'confirm_pin'
  post 'validate_pin', to: 'access_auth#validate_pin', as: 'validate_pin'
  post 'resend_pin', to: 'access_auth#resend_pin', as: 'resend_pin'
  post 'access_auth/select_niche', to: 'access_auth#select_niche', as: :access_auth_select_niche
  get 'deliverers/check', to: 'deliverers#check'
  get 'debug_logs', to: 'debug_logs#show_logs', as: :debug_logs


  resources :deliveries, only: [:new, :create, :index, :show]
  resources :deliverers, only: [:index, :show, :new, :create]
  resources :employees
  #devise_for :users
  devise_for :users, controllers: {
    sessions: 'users/sessions' # Aponta para o controller personalizado
  }
  resources :keylockers 
  #resources :email_settings

  resources :key_usages do
    collection  do
      get :saida
      get :entrada
    end
  end

  resources :employees do
    member do
      patch 'toggle_and_save_status'
      put 'reset_pin'
      post :send_sms_notification
    end
  end

  resources :keylockers do
    member do
      patch 'toggle_and_save_status'
      get 'generate_qr_delivery'
    end
  end


  patch 'manager_users/:id/toggle_finance', to: 'manager_users#toggle_finance', as: :toggle_finance
  patch 'manager_users/:id/toggle_role', to: 'manager_users#toggle_role', as: :toggle_role

  resources :manager_users do
    member do
      delete :destroy
    end
  end

  get '/history_entries', to: 'history_entries#index'

  resources :addresses, only: [:new, :create, :edit, :update, :destroy]

  resources :history_entries, only: [:index, :show, :new, :create, :destroy]

  #resources :sendsms, only: [:new, :create]

  resources :email_settings, only: [:new, :create, :edit, :update] do
    member do
      patch :update_email_setting
      patch :update_sendsms
    end
  
    collection do
      post :create_sendsms
    end
  end



  # config/routes.rb
  resources :user_lockers do
    member do
      post 'assign_keylocker'
      delete 'remove_keylocker/:keylocker_id', to: 'user_lockers#remove_keylocker', as: 'remove_keylocker'
    end
  end

  

  #resources :keylockers, defaults: { format: 'json' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :employees
      get 'information_locker', to: 'employees#information_locker'
      get '/find_by_serial_info_user', to: 'employees#find_by_serial_info_user'
      get '/employees', to: 'employees#index'
      get '/employees/:employee_id/belongs_to_keylocker/:keylocker_id', to: 'employees#belongs_to_keylocker'
      post '/esp8288params', to: 'employees#esp8288params', via: :post
      post 'check_user', to: 'employees#check_user'
      post 'toggle_door', to: 'employees#toggle_door'
      get '/check_card_access', to: 'employees#check_card_access'
      get '/check_keypad_access', to: 'employees#check_keypad_access'
      get '/:serial/employees', to: 'employees#employees_by_keylocker_card'
      post 'lockers/update_positions', to: 'employees#process_locker_code'
      get 'by_keylocker', to: 'employees#employees_by_keylocker'
      post 'locker_security', to: 'employees#locker_security'
      post 'control_exit_card', to: 'employees#control_exit_card'
      post 'control_exit', to: 'employees#control_exit'
      post 'control_exit_keypad', to: 'employees#control_exit_keypad'
      post 'control_locker_key', to: 'employees#control_locker_key'
      post '/check_access', to: 'employees#check_access'
      get 'list_employees', to: 'employees#list_employees'

      resources :keylockers  # Ajuste para o novo nome do controlador
      #post '/auth/sign_in', to: 'authentication#sign_in'
      devise_for :users, skip: [:registrations], controllers: {
        sessions: 'api/v1/auth/sessions'
      }
    end
  end
end
