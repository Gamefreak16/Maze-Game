require_relative './treasure_hunt.rb'


cave = Cave.new

cave.add_hazard(:guard, 1)
cave.add_hazard(:pit, 3)
cave.add_hazard(:bats, 3)

# Player and narrator setup

player    = Player.new
narrator  = Narrator.new

console = Console.new(player, narrator)

# Senses

player.sense(:bats) do
  console.haz("You hear a rustling sound nearby")
end

player.sense(:guard) do
  console.haz("You smell something terrible nearby")
end

player.sense(:pit) do
  console.haz("You feel a cold wind blowing from a nearby cavern.")
end

# Encounters

player.encounter(:guard) do
  player.act(:startle_guard, player.room)
end

player.encounter(:bats) do
  narrator.say "Giant bats whisk you away to a new cavern!"

  old_room = player.room
  new_room = cave.random_room

  player.enter(new_room)

  cave.move(:bats, old_room, new_room)
end

player.encounter(:pit) do
  narrator.finish_story("You fell into a bottomless pit. Enjoy the ride!")
end

# Actions

player.action(:move) do |destination|
  player.enter(destination)
end

player.action(:shoot) do |destination|
  if destination.has?(:guard)
    narrator.finish_story("YOU KILLED THE GUARD! GOOD JOB, BUDDY!!!")
  else
    narrator.say("Your arrow missed!")

    player.act(:startle_guard, cave.room_with(:guard))
  end
end

player.action(:startle_guard) do |old_guard_room|
  if [:move, :stay].sample == :move
    new_guard_room = old_guard_room.random_neighbor
    cave.move(:guard, old_guard_room, new_guard_room)

    narrator.say("You heard a rumbling in a nearby cavern.")
  end

  if player.room.has?(:guard)
    narrator.finish_story("You woke up the guard and he ate you!")
  end
end

# Kick off the event loop

roo = Room.new(800)
ro = Room.new(801)
r = Room.new(802)
roo.connect(ro)
roo.connect(r)
r.add(:pit)
ro.add(:guard)


player.enter(roo)


print player.explore_room