require_relative "../config/environment.rb"
require 'active_support/inflector' #gives us the pluralize method

class Song

#here we are going to use the column names of the songs table to dynamically
#create the attr_accessors of our Song class
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names #1) here we collect the column names. We are avoiding
    #explicitly referencing table and colum names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')" #query table for column names

    #iterate over the array of hashes to collect the name of each column
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row| #use column as row?
      column_names << row["name"]
    end
    column_names.compact #call compact on end to get rid of any nil values
  end

  #return will be ["id", "name", "album"]

  #below metaprograms our attribute accessors: self.table_name,
  #self.column_names, self.column_names.each

  def self.column_names.each do |col_name|
    attr_accessor col_name.to_sym #here we are setting an attr_accessor to each col_name
    #code is writing code for us here
  end


#This build us an abstract initialize method.
  def initialize(options={}) #defaults to an empty hash
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

#these are our abstracted table names
  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
#result: ["'the name of the song'", "'the album of the song'"]

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  #this returns "name, album"

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ? '#{name}'"
    DB[:conn].execute(sql)
  end

  #another way to code find_by_name
  # def self.find_by_name(name)
  # DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [name])
  # end

end

#*reminder string interpolation in a sql query causes string injections
