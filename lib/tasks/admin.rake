namespace :admin do

  desc 'Create admin account and send invitation email'
  task :create do
    user = User.create!(
      name: 'Admin',
      email: ENV['ADMIN_EMAIL'],
      password: Devise.friendly_token,
      admin: true
    )
    user.libraries.create!(name: 'My Library')
    user.send_reset_password_instructions
  end

end
