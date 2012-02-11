class DemoController < ApplicationController
  if BPS::Services.demo_mode?
    
    def blank_slate(options = {redirect: true})
      User.destroy_all
      Site.destroy_all
      BitcoinAddress.destroy_all
      Payment.destroy_all
      
      if options[:redirect]
        redirect_to root_path
      end
    end
    
    def setup_site(options = {redirect: true})
      blank_slate redirect: false

      site = Site.new name: "Bob's BPS"
      DBC.assert(site.save)

      user = User.new( 
        full_name: "Bob Smith", 
        email: "bob@example.com", 
        password: "super secret",
        password_confirmation: "super secret"
      )
      DBC.assert(user.save)
      
      Site.first.lock_to_owner!
      
      if options[:redirect]
        redirect_to root_path
      end
    end
    
    def sign_in(options = {redirect: true})
      setup_site redirect: false unless Site.locked_to_owner?
      
      session[:user_id] = User.first.id
      
      if options[:redirect]
        redirect_to admin_dashboard_path
      end
    end
   
    def add_bitcoin_address(options = {redirect: true})
      sign_in redirect: false unless Site.locked_to_owner?
      
      bitcoin = BPS::Bitcoin.random_address
      bitcoin.description = "1x socks\n2x red shirts - medium size"
      bitcoin.save!

      if options[:redirect]
        redirect_to admin_dashboard_path
      end
    end
    
    def add_payment(options = {redirect: true})
      add_bitcoin_address unless BitcoinAddress.count > 0
      Payment.create! bitcoin_address: BPS::Services.random(BitcoinAddress), 
        amount: (rand * 100)
      
      if options[:redirect]
        redirect_to admin_dashboard_path
      end
    end
    
  end
end