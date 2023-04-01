require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'sqlite3'
enable :sessions

def open_db()
    db = SQLite3::Database.new("db/data.db")
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
