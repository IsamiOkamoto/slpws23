require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'sqlite3'
enable :sessions
#Sökfunktion när man väljer då den visar slumpvis för det är för många saker, sökfunktion + stavningsfunktion
def open_db()
    db = SQLite3::Database.new("db/data.db")
    return db
end
def get_dex()
    db = SQLite3::Database.new("db/data.db")
    arr = []
    arr.append(db.execute("SELECT name FROM abilities"))
    arr.append(db.execute("SELECT name FROM items"))
    arr.append(db.execute("SELECT name FROM moves"))
    arr.append(db.execute("SELECT name FROM pokemon"))
    return arr
end
def get_ability_from_name(name)
    db = open_db()
    return db.execute("SELECT * FROM abilities WHERE name IS ?",name)
end
def get_move_from_name(name)
    db = open_db()
    return db.execute("SELECT * FROM moves WHERE name IS ?",name)
end
def get_item_from_name(name)
    db = open_db()
    return db.execute("SELECT * FROM items WHERE name IS ?",name)
end
def get_pokemon_from_name(name)
    db = open_db()
    return db.execute("SELECT * FROM pokemon WHERE name IS ?",name)
end
    get("/") do
    slim(:index)
end
get("/teams/new") do
    slim(:"teams/new")
end
post("/new_team") do
    name = params[:team_name]
    db = SQLite3::Database.new("db/data.db")
    db.execute("INSERT into ")
    redirect("/teams/edit")
end
post("/team/edit/poke") do
    #something
    redirect("teams/edit")
end
post("/teams/new_team") do
    redirect("teams/edit")
end
get("/teams/edit") do 
    #get team id from db, with create a team add team id so there is something to get
    
end
get("/teams/poke/edit") do
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    nature = db.execute("SELECT * FROM natures")
    items = db.execute("SELECT * FROM items")
    moves = db.execute("SELECT * FROM moves")
    poke = db.execute("SELECT * FROM pokemon")
    ability = db.execute("SELECT * FROM abilities")
    #team info
    slim(:"new_poke",locals:{nature:nature,items:items,moves:moves,poke:poke,ability:ability})
end
get("/myteams") do
    slim(:viewteams)
end
get("/dex") do
    arr = get_dex()
    slim(:"/dex/dex",locals:{arr:arr})
end
get("/dex/ability/:name") do
    name = params[:name]
    arr = get_ability_from_name(name)
    slim(:"dex/ability",locals:{arr:arr})
end
get("/dex/move/:name") do
    name = params[:name]
    arr = get_move_from_name(name)
    slim(:"dex/move",locals:{arr:arr})
end
get("/dex/item/:name") do
    name = params[:name]
    arr = get_item_from_name(name)
    slim(:"dex/item",locals:{arr:arr})
end
get("/dex/pokemon/:name") do
    name = params[:name]
    arr = get_pokemon_from_name(name)
    slim(:"dex/pokemon",locals:{arr:arr})
end