require 'sqlite3'

#creates the database
DB = {:conn => SQLite3::Database.new("db/songs.db")}
DB[:conn].execute("DROP TABLE IF EXISTS songs") #dropping songs to avoid
#an error

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true #results_as_hash is telling us to
#return a database row as a hash with column names as keys

#returns {"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello",
#2 => "25"}
