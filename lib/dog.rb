require 'pry'
class Dog

attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    
    # binding.pry
    @id = id
    @name = name
    @breed = breed
  end

  # def attributes(arguments)
  #   dog = Dog.new(arguments)
  # end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?,?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)

      sql = "SELECT last_insert_rowid() FROM dogs"
      self.id = DB[:conn].execute(sql).first.first
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, name, breed, id)
  end

  def self.new_from_db(arguments)
    dog = self.new(id: arguments[0], name: arguments[1], breed: arguments[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE name = ?
    SQL
  new_from_db(DB[:conn].execute(sql, name).first)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * 
      FROM dogs
      WHERE id = ?
    SQL

    new_from_db(DB[:conn].execute(sql, id).first)

    # if results.empty?
    #   raise "No Dog Found"
    # else 
    #   self.new(results.first) # pulls the single element from the array produced by .execute
    # end 

     # self.attributes(DB[:conn].execute(sql, id).first)
  end

  def self.create(name:, breed:)
    # binding.pry
    dog = Dog.new(name: name, breed: breed) #works with dog = Dog.new(arguments)
    dog.save
    dog
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
    SELECT * 
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    # binding.pry
    results = DB[:conn].execute(sql, name, breed).first
    # binding.pry
    if results == nil
      create(name: name, breed: breed)
    else
      new_from_db(results)
    end
  end



end


