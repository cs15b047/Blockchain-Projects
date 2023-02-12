''' A simple implementation of battleship in Vyper '''

# NOTE: The provided code is only a suggestion
# You can change all of this code (as long as the ABI stays the same)

NUM_PIECES: constant(uint32) = 5
BOARD_SIZE: constant(uint32) = 5

# What phase of the game are we in ?
# Start with SET and end with END
PHASE_SET: constant(int32) = 0
PHASE_SHOOT: constant(int32) = 1
PHASE_END: constant(int32) = 2

# Each player has a 5-by-5 board
# The field track where the player's boats are located and what fields were hit
# Player should not be allowed to shoot the same field twice, even if it is empty
FIELD_EMPTY: constant(int32) = 0
FIELD_BOAT: constant(int32) = 1
FIELD_HIT: constant(int32) = 2

players: immutable(address[2])

# Which player has the next turn? Only used during the SHOOT phase
next_player: uint32

# Which phase of the game is it?
phase: int32

# Board
board2D: int32[5][5][2]
boats: uint32[2]

@external
def __init__(player1: address, player2: address):
    players = [player1, player2]
    self.next_player = 0
    self.phase = PHASE_SET

    #TODO initialize whatever you need here
    # Init both boards to empty
    for p in range(2):
        for i in range(5):
            for j in range(5):
                self.board2D[p][i][j] = FIELD_EMPTY
    self.boats = [0, 0]

@external
def set_field(pos_x: uint32, pos_y: uint32):
    '''
    Sets a ship at the specified coordinates
    This should only be allowed in the initial phase of the game

    Players are allowed to call this out of order,
    but at most NUM_PIECES times
    '''
    if self.phase != PHASE_SET:
        raise "Wrong phase"

    if pos_x >= BOARD_SIZE or pos_y >= BOARD_SIZE:
        raise "Position out of bounds"

    #TODO add the rest here
    player: uint32 = self.get_player()
    # Limit the number of boats that can be set
    if self.boats[player] == NUM_PIECES:
        raise "Already set all boats"

    # Set the field to a boat if it is empty
    if self.board2D[player][pos_x][pos_y] != FIELD_EMPTY:
        raise "Field already set"

    self.board2D[player][pos_x][pos_y] = FIELD_BOAT
    self.boats[player] += 1

    # If all boats are set, move to the next phase
    if self.boats[0] == NUM_PIECES and self.boats[1] == NUM_PIECES:
        self.phase = PHASE_SHOOT

@external
def shoot(pos_x: uint32, pos_y: uint32):
    '''
    Shoot a specific field on the other players board
    This should only be allowed if it is the calling player's turn and only during the SHOOT phase
    '''

    if pos_x >= BOARD_SIZE or pos_y >= BOARD_SIZE:
        raise "Position out of bounds"

    if self.phase != PHASE_SHOOT:
        raise "Wrong phase"

    # Add shooting logic and victory logic here
    player: uint32 = self.get_player()
    hit_player: uint32 = 1 - player

    if player != self.next_player:
        raise "Not your turn"

    if self.board2D[hit_player][pos_x][pos_y] == FIELD_HIT:
        raise "Already hit this field"
    
    # If the field is a boat, decrement the number of boats
    if self.board2D[hit_player][pos_x][pos_y] == FIELD_BOAT:
        self.boats[hit_player] -= 1
    self.board2D[hit_player][pos_x][pos_y] = FIELD_HIT
    
    if self.is_game_over():
        self.phase = PHASE_END
    else:
        self.next_player = 1 - self.next_player

@internal
def get_player() -> uint32:
    ''' Returns the index of the player who's turn it is '''
    if msg.sender == players[0]:
        return 0
    elif msg.sender == players[1]:
        return 1
    else:
        raise "Not a player"

@internal
def is_game_over() -> bool:
    ''' Returns true if the game is over and false otherwise'''
    if self.boats[0] == 0 or self.boats[1] == 0:
        return True
    return False

@external
@view
def has_winner() -> bool:
    return self.phase == PHASE_END

@external
@view
def get_winner() -> address:
    ''' Returns the address of the winner's account '''

    #TODO figure out who won --> boat pieces == 0 --> other player won
    if self.boats[0] == 0:
        return players[1]
    elif self.boats[1] == 0:
        return players[0]

    # Raise an error if no one won yet
    raise "No one won yet"
