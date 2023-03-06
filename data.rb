require 'sqlite3'
require 'csv'

def reader()
    return CSV.read("pokemondata.csv")
end

def add()
    arr = reader()
    db = SQLite3::Database.new("db/data.db")
    arr.each do |row|
        db.execute("INSERT INTO pokemon (name, img) VALUES (?,?)", row[0], "#{row[0]}.png")
    end
end
def tester()
    arr = reader()
    p arr[0]
    p arr[1]
end
def delete()
    db = SQLite3::Database.new("db/data.db")
    db.execute("DELETE FROM items")
end
CSV.foreach(file,{headers: :first_row, quote_char: "\x00"}) do |line|
    p line
end