require 'sinatra'
require 'sinatra/reloader'
require 'bcrypt'
require 'sqlite3'
enable :sessions
#Sökfunktion när man väljer då den visar slumpvis för det är för många saker, sökfunktion + stavningsfunktion
def open_db()
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
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
    db = SQLite3::Database.new("db/data.db")
    return db.execute("SELECT * FROM abilities WHERE name IS ?",name)
end
def get_move_from_name(name)
    db = SQLite3::Database.new("db/data.db")
    return db.execute("SELECT * FROM moves WHERE name IS ?",name)
end
def get_item_from_name(name)
    db = SQLite3::Database.new("db/data.db")
    return db.execute("SELECT * FROM items WHERE name IS ?",name)
end
def get_pokemon_from_name(name)
    db = SQLite3::Database.new("db/data.db")
    return db.execute("SELECT * FROM pokemon WHERE name IS ?",name)
end
def from_name(name, list)
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    return db.execute("SELECT * FROM #{list} WHERE name IS ?", name)
  end
get("/") do
    slim(:index)
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
get("/signup") do
    slim(:signup)
end
post("/users/new") do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new("db/data.db")
    db.execute("INSERT INTO users (username, password) VALUES (?,?)",username, password_digest)
    redirect("/")
  else
    "Passwords don't match"
  end
end
post("/login") do
    username = params[:username]
    session[:user] = username
    password = params[:password]   
    db = SQLite3::Database.new("db/data.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    if result == nil
        "Username not found"
    else
        passsword = result["password"]
        if BCrypt::Password.new(passsword) == password
        session[:user] = username
        session[:id] = result["id"]
        redirect("/")
        else
        "Username and passwords do not match"
        end
    end
end
get("/login") do 
    slim(:login)
end
get("/account") do
    slim(:account)
end
get("/pokemon/new") do
    db = open_db()
    result = db.execute("SELECT * FROM pokemon")
    slim(:"pokemon/new1",locals:{result:result})
end
get("/pokemon/new/:id") do
    name = params[:id]
    db = open_db()
    pokemon = db.execute("SELECT * FROM pokemon WHERE name IS ?",name)
    nature = db.execute("SELECT * FROM natures")
    item = db.execute("SELECT * FROM items")
    moves = db.execute("SELECT * FROM moves")
    ability = db.execute("SELECT * FROM abilities")
    slim(:"pokemon/new",locals:{pokemon:pokemon,nature:nature,item:item,moves:moves,ability:ability})
end
post("/pokemon/new/pokemon") do
    pokemon = params[:pokemon]
    nickname = params[:nickname]
    item = params[:item]
    nature = params[:nature]
    mov1 = params[:move1]
    mov2 = params[:move2]
    mov3 = params[:move3]
    mov4 = params[:move4]
    ability = params[:ability]
    db = open_db()
    db = SQLite3::Database.new("db/data.db")
    pokemon_id = from_name(pokemon, "pokemon")
    item_id = from_name(item, "items")
    nature_id = from_name(nature, "natures")
    mov1_id = from_name(mov1, "moves")
    mov2_id = from_name(mov2, "moves")
    mov3_id = from_name(mov3, "moves")
    mov4_id = from_name(mov4, "moves")
    ability_id = from_name(ability, "abilities")
    db.execute("INSERT INTO poke_in_team(nickname, move_one_id, move_two_id, move_three_id, move_four_id, nature_id, item_id, pokemon_id, user_id, ability_id, in_teams) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",nickname, mov1_id[0]["id"], mov2_id[0]["id"], mov3_id[0]["id"], mov4_id[0]["id"], nature_id[0]["id"], item_id[0]["id"], pokemon_id[0]["id"], session[:id], ability_id[0]["id"], "")
    redirect("/pokemon/")
end
get("/pokemon/") do
    db = open_db()
    result = db.execute("SELECT * FROM poke_in_team WHERE user_id IS ?",session[:id])
    arr = []
    result.each do |hash|
        ap =[]
        if hash["nickname"] != nil
            ap.append(hash["nickname"])
        else
            ap.append(db.execute("SELECT name FROM pokemon WHERE id IS ?", hash["pokemon_id"]))
        end
        ap.append(db.execute("SELECT * FROM pokemon WHERE id IS ?", hash["pokemon_id"]))
        ap.append(db.execute("SELECT * FROM natures WHERE id IS ?", hash["nature_id"]))
        ap.append(db.execute("SELECT * FROM items WHERE id IS ?", hash["item_id"]))
        ap.append(db.execute("SELECT * FROM abilities WHERE id IS ?", hash["ability_id"]))
        ap.append(db.execute("SELECT * FROM moves WHERE id IS ?", hash["move_one_id"]))
        ap.append(db.execute("SELECT * FROM moves WHERE id IS ?", hash["move_two_id"]))
        ap.append(db.execute("SELECT * FROM moves WHERE id IS ?", hash["move_three_id"]))
        ap.append(db.execute("SELECT * FROM moves WHERE id IS ?", hash["move_four_id"]))
        arr.append(ap)
    end
    slim(:"pokemon/index",locals:{result:result,arr:arr})
end
get("/pokemon/:id/edit") do
    id = params[:id]
    db = open_db()
    current = db.execute("SELECT * FROM poke_in_team WHERE id IS ?",id)
    nature = db.execute("SELECT * FROM natures")
    item = db.execute("SELECT * FROM items")
    moves = db.execute("SELECT * FROM moves")
    ability = db.execute("SELECT * FROM abilities")
    slim(:"pokemon/update",locals:{current:current,nature:nature,item:item,moves:moves,ability:ability})
end
#belong to team
post("/pokemon/:id/delete") do
    id = params[:id]
    db = open_db()
    db.execute("DELETE FROM poke_in_team WHERE id IS ?",id)
    redirect("/pokemon/show")
end
post("/pokemon/:id/update") do
    id = params[:id]
    nickname = params[:nickname]
    item = params[:item]
    nature = params[:nature]
    mov1 = params[:move1]
    mov2 = params[:move2]
    mov3 = params[:move3]
    mov4 = params[:move4]
    ability = params[:ability]
    db = open_db()
    db = SQLite3::Database.new("db/data.db")
    item_id = from_name(item, "items")
    nature_id = from_name(nature, "natures")
    mov1_id = from_name(mov1, "moves")
    mov2_id = from_name(mov2, "moves")
    mov3_id = from_name(mov3, "moves")
    mov4_id = from_name(mov4, "moves")
    ability_id = from_name(ability, "abilities")
    db.execute("UPDATE poke_in_team SET nickname=?, move_one_id=?, move_two_id=?, move_three_id=?, move_four_id=?, nature_id=?, item_id=?, ability_id=? WHERE id IS ?",nickname, mov1_id[0]["id"], mov2_id[0]["id"], mov3_id[0]["id"], mov4_id[0]["id"], nature_id[0]["id"], item_id[0]["id"],  ability_id[0]["id"], id)
    redirect("/pokemon/show")
end
get("/teams/new") do
    db = open_db()
    result = db.execute("SELECT * FROM poke_in_team WHERE user_id=?", session[:id])
    result2 = db.execute("SELECT * FROM poke_in_team WHERE user_id IS NOT ?", session[:id])
    pokemon = db.execute("SELECT * FROM pokemon")
    arr = []
    result.each do |hash|
        arr.append(db.execute("SELECT name FROM pokemon WHERE id=?", hash["pokemon_id"]).first)
    end
    result2.each do |hash|
        arr.append(db.execute("SELECT name FROM pokemon WHERE id=?", hash["pokemon_id"]).first)
    end
    slim(:"teams/new",locals:{result:result,result2:result2,pokemon:pokemon,arr:arr})
end
get("/teams/") do
    slim(:"/teams/index")
end
post("/teams/new") do
    poke1 = params[:poke1_own]
    if poke1 == ""
        poke1 = params[:poke1_other]
    end
    poke2 = params[:poke2_own]
    if poke2 == ""
        poke2 = params[:poke2_other]
    end
    poke3 = params[:poke3_own]
    if poke3 == ""
        poke3 = params[:poke3_other]
    end
    poke4 = params[:poke4_own]
    if poke4 == ""
        poke4 = params[:poke4_other]
    end
    poke5 = params[:poke5_own]
    if poke5 == ""
        poke5 = params[:poke5_other]
    end
    poke6 = params[:poke6_own]
    if poke6 == ""
        poke6 = params[:poke6_other]
    end
    db = SQLite3::Database.new("db/data.db")
    name = params[:team_name]
    db.execute("INSERT INTO teams (user_id, team_name, poke_one_id, poke_two_id, poke_three_id, poke_four_id, poke_five_id, poke_six_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",session[:id], name, poke1, poke2, poke3, poke4, poke5, poke6)
    arr = [poke1, poke2, poke3, poke4, poke5, poke6]
    arr1 = []
    arr.each do |id|
        arr1.append(db.execute("SELECT in_teams FROM poke_in_team WHERE id IS ?", id).first)
    end
    id = db.execute("SELECT id FROM teams ORDER BY id DESC LIMIT 1;")
    i = 0
    arr1.each do
        arr1[i][0] = arr1[i][0] + id[0][0].to_s + ","
        i += 1
    end
    i = 0
    arr1.each do |ar|
        db.execute("UPDATE poke_in_team SET in_teams=? WHERE id IS ?",ar[0], arr[i])
        i += 1
    end
    redirect("/teams/")
end