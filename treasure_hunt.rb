########### Jake Hoffman ###########
########### jathoffman ###########
########### 113171590 ###########

class ValueError < RuntimeError
end

class Cave
  def initialize()
    @edges = [[1, 2], [2, 10], [10, 11], [11, 8], [8, 1], [1, 5], [2, 3], [9, 10], [20, 11], [7, 8], [5, 4],
                      [4, 3], [3, 12], [12, 9], [9, 19], [19, 20], [20, 17], [17, 7], [7, 6], [6, 5], [4, 14], [12, 13],
                      [18, 19], [16, 17], [15, 6], [14, 13], [13, 18], [18, 16], [16, 15], [15, 14]]
    @rooms = {}
    1.upto(20){|x| @rooms[x] = Room.new(x)}
    @edges.each{|x| @rooms[x[0]].connect(@rooms[x[1]])}
  end
  attr_reader :rooms
  

  def add_hazard(thing, count)
    arr = Array.new
    while arr.length < count
      num = Random.rand(1..20)
      unless arr.include?(num)
        arr.push(num)
      end
    end
    arr.each{|x| @rooms[x].add(thing)}
  end

  def random_room
    val = Random.rand(1..20)
    @rooms[val]
  end

  def move(thing, frm, to)
    frm.remove(thing)
    to.add(thing)
  end

  def room_with(thing)
    @rooms.values.find {|v| v.hazards.include?(thing) }
  end

  def entrance
    @rooms.values.find {|v| v.safe?}
  end

  def room(number)
    if @rooms[number].nil?
      raise KeyError
    end
    @rooms[number]
  end
end

class Player
  attr_reader  :senses, :encounters, :actions, :room

  def initialize
    @senses = Hash.new
    @encounters = Hash.new
    @actions = Hash.new
    @room = nil
  end

  def sense(thing, callback)
    @senses[thing] = callback
  end

  def encounter(thing, &callback)
    @encounters[thing] = callback
  end

  def action(thing, &callback)
    @actions[thing] = callback
  end

  def enter(room)
    @room = room
    unless @room.empty?
      kee = @encounters.keys.find{|x| @room.hazards.include?(x)}
      @encounters[kee].call
    end
  end

  def explore_room
    lis = []
    @room.neighbors.each {|x| x.hazards.each{|y| lis.push(@senses[y])}}
    return lis
  end

  def act(action, destination)
    @actions.fetch(action).call(destination)
  end
end

class Room
  attr_reader :number, :hazards, :neighbors

  def initialize(number)
    @number = number
    @hazards = Array.new
    @neighbors = Array.new
  end

  def add(thing)
    @hazards.push(thing)
  end

  def remove(thing)
    if not @hazards.include?(thing)
      raise ValueError
    end
    @hazards.delete(thing)
  end

  def has?(thing)
    return @hazards.include?(thing)
  end

  def empty?
    return @hazards.empty?
  end

  def safe?
    if not self.empty?
      return false
    else
      arr = Array.new
      @neighbors.each{|x| arr.push(x.empty?)}
      if arr.include?(false)
        return false
      end
    end
    return true
  end

  def connect(other_room)
    @neighbors.push(other_room)
    other_room.neighbors.push(self)
  end

  def exits
    arr = Array.new
    @neighbors.each{|x| arr.push(x.number)}
    return arr
  end

  def neighbor(number)
    return @neighbors.find {|x| x.number == number}
  end

  def random_neighbor
    if @neighbors.empty?
      raise IndexError
    end
    rng = Random.new
    numbo = rng.rand(@neighbors.size)
    @neighbors[numbo]
  end
end

class Console
  @@cons = nil

  def initialize(player, cave)
    @player   = player
    @cave = cave
    @reaction = ""
  end

  def Console.make(player, cave)
    @@cons = Console.new(player, cave)
    return @@cons
  end

  def Console.get
    return @@cons
  end

  def setReact(message)
    @reaction = message
  end

  def react(action, room)
    actions = {"m" => :move, "s" => :shoot}
    unless ["m","s"].include?(action)
      @reaction = "Invalid action! Try again!"
      return
    end

    unless @player.room.exits.include?(room)
      @reaction = "Invalid destination! Try again!"
      return
    end
    # @reaction = "eggo my leggo"
    # return
    @player.act(actions[action], @player.room.neighbor(room))
  end

  attr_reader :player, :cave, :reaction

  def player_exits
    @player.room.exits.join(', ')
  end

  def explore_room
    @player.explore_room
  end


  def haz(strin)
    return strin
  end


  def current_room
    @player.room.number
  end

  def enter(roobo)
    @player.enter(roobo)
  end

  
end
