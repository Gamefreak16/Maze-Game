###### Jake Hoffman #######


require_relative "./treasure_hunt.rb"
require "rubygems"
require "sinatra"
require "time"

get '/' do
    @time = Time.now
    erb :home
end


after '/' do
    cave = Cave.new
    cave.add_hazard(:guard, 1)
    cave.add_hazard(:pit, 3)
    cave.add_hazard(:bats, 3)

    # Player and narrator setup

    player = Player.new
    Console.make(player, cave)

    # Senses

    player.sense(:bats, "You hear a rustling sound nearby")
    
    player.sense(:guard, "You smell something terrible nearby")
      
    player.sense(:pit,"You feel a cold wind blowing from a nearby cavern.")

    # Encounters

    player.encounter(:guard) do
        player.act(:startle_guard, player.room)
        
    end

    player.encounter(:bats) do
        old_room = player.room
        new_room = cave.random_room
        player.enter(new_room)
        cave.move(:bats, old_room, new_room)
        Console.get.setReact("Giant bats whisk you away to a new cavern!")
    end

    player.encounter(:pit) do
        Console.get.setReact("end")
    end

    # Actions

    player.action(:move) do |destination|
        Console.get.setReact("")
        player.enter(destination)
    end

    player.action(:shoot) do |destination|
        if destination.has?(:guard)
            Console.get.setReact("win")
        else
            player.act(:startle_guard, cave.room_with(:guard))
            Console.get.setReact("Your arrow missed!")
        end
    end

    player.action(:startle_guard) do |old_guard_room|
        if [:move, :stay].sample == :move
            new_guard_room = old_guard_room.random_neighbor
            cave.move(:guard, old_guard_room, new_guard_room)
            Console.get.setReact("You heard a rumbling in a nearby cavern.")
        end

        if player.room.has?(:guard)
            Console.get.setReact("end")
        end
    end
    player.enter(cave.entrance)
#     roo = Room.new(800)
# ro = Room.new(801)
# r = Room.new(802)
# roo.connect(ro)
# roo.connect(r)
# r.add(:bats)
# ro.add(:bats)
# player.enter(roo)
end

before '/play_game' do
    @console = Console.get
end


get '/play_game' do
    

    
    erb :play_game
end





put '/play_game' do
    act = params[:faction].strip
    rooo = params[:froom].strip.to_i
    #file = File.new("output", "w")
    # file.puts act, "  ", rooo, 
    # @console.cave.rooms[rooo].number, 
    # @console.player.room.exits.include?(@console.cave.rooms[rooo]),
    # @console.player.room.exits,
    # @console.player.room
    # file.close
    @console.react(act, rooo)
    # file.puts @console.reaction
    # file.close

    if @console.reaction == "win"
        redirect '/winner'
    elsif @console.reaction == "end"
        redirect '/endgame'
    else
        redirect '/play_game'
    end

end



get '/endgame' do
    erb :game_over
end

get '/winner' do
    erb :winner

end
