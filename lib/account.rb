require 'csv'
require 'date'


# Bank module contains Account class and any future bank account logic.
module Bank
  class Account
    # allows access to the current balance of an account at any time.
    attr_accessor :balance, :owner
    # only allow reader on unique account id, and opendate
    attr_reader :id, :open_date

    # constructs a new Account object
    # give a default value, in case the Owner class object is not passed
    # assumes passed parameters are formated in their correct data type.
    def initialize id, balance, open_date, owner = nil

      # error handling for initial negative balance
      if balance >= 0
        @balance = balance
      else
        raise ArgumentError.new "Inital balance cannot be a negetive value"
      end

      @id = id
      @open_date = DateTime.parse(open_date)

      # assumes that required csv file is accesible
      CSV.read("support/account_owners.csv").each do |line|
        if line[0].to_i == @id
          @owner = Bank::Owner.find(line[1].to_i)
        end
      end

      if owner.class == Bank::Owner
        @owner = owner
      else
        # default instance of the Owner class initialized with empty hash
        @owner = Bank::Owner.new({})
      end
    end

    # method that returns a collection of Account instances, from data read in CSV
    def self.all
      all_accounts_array= []
      #for efficiency, consider setting all_accounts_array to a class variable
      CSV.read("support/accounts.csv").each do |line|
        all_accounts_array << Bank::Account.new( line[0].to_i, line[1].to_i, line[2] )
      end

      return all_accounts_array
    end

    # method that returns an instance of an Account class, where the value of the id field
    # in the CSV matches the passed parameter
    def self.find(id)
      raise ArgumentError.new ("Account id must be a positive integer value") if ( id.class != Integer || id < 1 )

      CSV.read("support/accounts.csv").each do |line|
        if line[0].to_i == id
          account = Bank::Account.new( line[0].to_i, line[1].to_i, line[2])
          return account
        end
      end
      raise ArgumentError.new "Account id does not exist in the database"
    end


    # method that overwrites existing empty @owner instance variable
    def update_owner_data(owner_hash)
      #only overwrite if initially not added to account at the time of initializing account object
      #note: in the future, consider being able to update names, addess, phone number for existing @owners
      if @owner.id == 0
        @owner = Bank::Owner.new(owner_hash)
      end
    end

    # method that handles withdraw
    def withdraw(withdraw_amount)
      # error handling for insufficient funds for a withdraw
      raise ArgumentError.new ("Withdraw amount must be a positive numericla value") if ( !(withdraw_amount.class == Integer || withdraw_amount.class == Float) || withdraw_amount < 0 )
      # insufficient funds
      if @balance < withdraw_amount
        puts "You do not have sufficient funds to withdraw the entered amount"
      # negative withdraw amount, invalid
    elsif withdraw_amount < 0
        raise ArgumentError.new "Withdraw amount cannot be a negetive value"
      # allow withdraw
      else
        @balance -= withdraw_amount
      end
      return @balance
    end

    # method that handles deposits
    def deposit(money_amount)
      # negative deposit amount, invalid
      if money_amount < 0
        raise ArgumentError.new "Deposit amount cannot be a negetive value"
      else
        @balance += money_amount
        return @balance
      end
    end
  end
end
