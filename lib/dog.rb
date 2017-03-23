# Dog
#   attributes
# F    has a name and a breed (FAILED - 1)
# F    has an id that defaults to `nil` on initialization (FAILED - 2)
# F    accepts key value pairs as arguments to initialize (FAILED - 3)
#   ::create_table
# F    creates the dogs table in the database (FAILED - 4)
#   ::drop_table
# F    drops the dogs table from the database (FAILED - 5)
#   #save
# F    returns an instance of the dog class (FAILED - 6)
# F    saves an instance of the dog class to the database and then sets the given dogs `id` attribute (FAILED - 7)
#   ::create
# F    takes in a hash of attributes and uses metaprogramming to create a new dog object. Then it uses the #save method to save that dog to the database (FAILED - 8)
# F    returns a new dog object (FAILED - 9)
require 'pry'
class Dog
  attr_accessor :name, :breed , :id
  def initialize(options={})
    @name = options[:name]
    @breed = options[:breed]
    options[:id] ?  @id = options[:id] : @id = nil
  end

  def self.create_table
    #check if table already exists
    #IF NOT EXISTS
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
      name text,
      breed text,
      id INTEGER PRIMARY KEY
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    #save the instance to the DB
    #check if record exists by checking unique id not set to nil
    if self.id
      self.update
      return self
    else
      sql = "INSERT INTO dogs (name,breed) VALUES (?,?)"
      DB[:conn].execute(sql, self.name, self.breed)
      # return the id of the last entry
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def self.create(hash)
    #creates a student object then saves it to the DB
    Dog.new(hash).save
  end

  def self.new_from_db(entry)
    new_dog = Dog.new({:name => entry[1], :breed => entry[2]})
    new_dog.id = entry[0]
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    Dog.new_from_db(DB[:conn].execute(sql,id)[0]) #return an array at result[0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    Dog.new_from_db(DB[:conn].execute(sql,name)[0]) #return an array at result[0]
  end

  def self.find_or_create_by(name:, breed:) #passing in a hash as an argument
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name , breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new({id: dog_data[0], :name => dog_data[1], :breed => dog_data[2]})
    else
      dog = self.create({name: name, breed: breed})
    end
    dog
  end

  def update
    #running update query on the record using the unique key of the object as the id selector
    sql = <<-SQL
        UPDATE dogs
        SET name = ? , breed = ? WHERE id = ?
        SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end

# def self.find_or_create_by(name:, breed:)
#    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'")
#    if !dog.empty?
#      dog_data = dog[0]
#      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
#    else
#      dog = self.create(name: name, breed: breed)
#    end
#    dog
#  end

# def self.find_or_create_by(name:, album:)
#   song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, album)
#   if !song.empty?
#     song_data = song[0]
#     song = Song.new(song_data[0], song_data[1], song_data[2])
#   else
#     song = self.create(name: name, album: album)
#   end
#   song
# end
